import 'package:archive/archive.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

import 'package:pritt_server/src/main/adapter/adapter.dart';
import 'package:pritt_server/src/main/adapter/adapter/resolve.dart';
import 'package:pritt_server/src/main/adapter/adapter/result.dart';
import 'package:pritt_server/src/main/crs/response.dart';

final goAdapter = Adapter(
    id: 'go',
    language: 'go',
    resolve: (resolve) {
      if (resolve.userAgent.toString().startsWith('Go-http-client')) {
        if (resolve.query['go-get'] == '1') {
          // initial retrieve
          resolve.addMeta('stage', '1');
          return AdapterResolveType.meta;
        } else if (resolve.pathSegments.first ==
                resolve.url.replaceFirst('api.', '') ||
            resolve.url.startsWith('localhost')) {
          if (resolve.pathSegments.last == 'list') {
            resolve.addMeta('stage', '2');
            return AdapterResolveType.meta;
          }
          if (resolve.pathSegments.last.endsWith('.zip')) {
            return AdapterResolveType.archive;
          } else if (resolve.pathSegments.last.endsWith('.info') ||
              resolve.pathSegments.last.endsWith('.mod')) {
            resolve.addMeta('stage', '2');
            return AdapterResolveType.meta;
          }
        }
      }
      return AdapterResolveType.none;
    },
    request: (req, crs) async {
      // multiple variants
      if (req.env['stage'] == '1') {
        final url = Uri.parse(req.resolveObject.url)
            .replace(path: req.resolveObject.path);
        // stage 1 -- simple html
        final htmlDoc = Document()
          ..append(Element.tag('html')
            ..append(Element.tag('head')
              ..append(Element.tag('meta')
                ..attributes.addAll({
                  'name': 'go-import',
                  'content':
                      '${url.host}/${url.path} mod ${url.replace(path: '').toString()}'
                }))
              ..append(Element.tag('meta'))));

        // send down html
        return AdapterMetaResult(htmlDoc.outerHtml,
            responseType: ResponseType.html);
      } else if (req.env['stage'] == '2') {
        final segments = req.resolveObject.pathSegments;
        final prevSegment = segments[segments.indexOf('@v') - 1];
        final pkgName =
            req.resolveObject.url.contains(prevSegment) ? null : prevSegment;
        final otherSegments = segments.sublist(segments.indexOf('@v'));
        if (pkgName != null) {
          if (req.resolveObject.path.endsWith('@v/list')) {
            // list all versions
            final pkgVersResult = crs.getPackagesStream(pkgName);
            if (!pkgVersResult.isSuccess) {
              return AdapterErrorResult(
                  'bad request: ${(pkgVersResult as CRSErrorResponse).error}',
                  statusCode: 404,
                  responseType: ResponseType.plainText);
            }

            final versions = pkgVersResult.body!.map((p) => 'v${p.version}');

            return AdapterMetaResult(await versions.join('\n'),
                responseType: ResponseType.plainText);
          } else {
            // break down and get version
            final versionWithExtension = otherSegments.last;
            final extension = p.extension(versionWithExtension);
            var version = versionWithExtension.replaceAll(extension, '');
            if (version.startsWith('v')) version = version.substring(1);

            // get package information
            final pkgVerResult =
                await crs.getPackageWithVersion(pkgName, version);
            if (!pkgVerResult.isSuccess) {
              return AdapterErrorResult(
                  'bad request: ${(pkgVerResult as CRSErrorResponse).error}',
                  statusCode: 404,
                  responseType: ResponseType.plainText);
            }

            // check extension
            switch (extension) {
              case '.info':
                // get name and pub
                final pkgVerResult =
                    await crs.getPackageWithVersion(pkgName, version);
                if (!pkgVerResult.isSuccess) {}
                var metaResult = {
                  'Version': 'v$version',
                  'Time': pkgVerResult.body!.created.toIso8601String(),
                };
                return AdapterMetaResult(metaResult,
                    responseType: ResponseType.json);
              case '.mod':
                return AdapterMetaResult(pkgVerResult.body!.config,
                    responseType: ResponseType.plainText);
              default:
                return AdapterErrorResult(
                    'bad request: unexpected extension "$extension"',
                    statusCode: 404,
                    responseType: ResponseType.plainText);
            }
          }
        } else {
          return AdapterErrorResult(
              'not found: $prevSegment is a known non-module');
        }
      }
      return AdapterErrorResult('bad request',
          statusCode: 404, responseType: ResponseType.plainText);
    },
    retrieve: (req, crs) async {
      final segments = req.resolveObject.pathSegments;
      final prevSegment = segments[segments.indexOf('@v') - 1];
      final pkgName =
          req.resolveObject.url.contains(prevSegment) ? null : prevSegment;
      if (pkgName == null)
        return AdapterErrorResult(
            'bad request: $prevSegment is a known non-module',
            statusCode: 404,
            responseType: ResponseType.plainText);

      final versionWithExtension = segments.last;
      final extension = p.extension(versionWithExtension);
      var version = versionWithExtension.replaceAll(extension, '');
      if (version.startsWith('v')) version = version.substring(1);

      // get the archive as a tarball
      List<int> tarBytes;
      final archiveResult = await crs.getArchiveWithVersion(pkgName, version);
      if (!archiveResult.isSuccess) {}
      final archive = TarDecoder().decodeBytes(GZipDecoder()
          .decodeBytes(await ByteStream(archiveResult.body!.data).toBytes()));
      final zipArchive = ZipEncoder().encode(archive);
      return AdapterArchiveResult(ByteStream.fromBytes(zipArchive ?? []),
          '${req.resolveObject.url}/${req.resolveObject.path}@v$version');
    });
