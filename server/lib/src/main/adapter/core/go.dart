import 'package:archive/archive.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:pritt_common/functions.dart';
import 'package:pritt_common/version.dart';

import '../../crs/response.dart';
import '../adapter.dart';
import '../adapter/adapter_base_result.dart';
import '../adapter/resolve.dart';
import '../adapter/result.dart';

final goAdapter = Adapter(
  id: 'go',
  language: 'go',
  resolve: (resolve) {
    if (resolve.userAgent.toString().startsWith('Go-http-client')) {
      if (resolve.query['go-get'] == '1') {
        // initial retrieve
        resolve.addMeta('stage', '1');
        return AdapterResolveType.meta;
        // TODO: Get actual URL routing for Go adapter
      } else {
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
      final url = Uri.parse(
        req.resolveObject.url,
      ).replace(path: req.resolveObject.path);
      // stage 1 -- simple html
      final htmlDoc = Document()
        ..append(
          Element.tag('html')..append(
            Element.tag('head')
              ..append(
                Element.tag('meta')
                  ..attributes.addAll({
                    'name': 'go-import',
                    'content':
                        '${url.host}/${url.path} mod ${url.replace(path: '').toString()}',
                  }),
              )
              ..append(Element.tag('meta')),
          ),
        );

      // send down html
      return CoreAdapterMetaResult(
        htmlDoc.outerHtml,
        responseType: ResponseType.html,
      );
    } else if (req.env['stage'] == '2') {
      // get the path segments
      final segments = req.resolveObject.pathSegments;

      // match the path segments
      if (segments.contains('@latest')) {
        final [base, ...parts] = segments.sublist(
          0,
          segments.indexOf('@latest'),
        );
        final (name, scope) = switch (parts) {
          [String name] => (name, null),
          [String scope, String name] => (name, scope),
          _ => (parts.last, parts.first == parts.last ? null : parts.first),
        };

        // get latest version
        final latestPkgResponse = await crs.getLatestPackage(
          scopedName(name, scope),
        );
        if (latestPkgResponse case CRSErrorResponse(error: final err, statusCode: final statusCode))
          return CoreAdapterErrorResult(
            'bad request: no package',
            statusCode: statusCode ?? 404,
            responseType: ResponseType.plainText,
          );

        final latestPkg = latestPkgResponse.body!;

        final metaResult = {
          'Version': 'v${latestPkg.version}',
          'Time': latestPkg.created.toIso8601String(),
        };
        return CoreAdapterMetaResult(
          metaResult,
          responseType: ResponseType.json,
        );
      }

      final positionOfAtV = segments.indexOf('@v');
      if (segments.sublist(0, positionOfAtV).length == 1) {
        // get all versions
        // for now we do not support this
        // TODO: throw
        return CoreAdapterErrorResult(
          'bad request: unsupported',
          statusCode: 404,
          responseType: ResponseType.plainText,
        );
      }
      final [base, ...parts] = segments.sublist(0, positionOfAtV);
      final requestRequirements = segments.sublist(positionOfAtV + 1).first;

      // get name
      final (name, scope) = switch (parts) {
        [String name] => (name, null),
        [String scope, String name] => (name, scope),
        _ => (parts.last, parts.first == parts.last ? null : parts.first),
      };

      // now match requirements
      if (requestRequirements == 'list') {
        // list versions
        final pkgVersResult = crs.getPackagesStream(
          scopedName(name, scope),
          env: {
            'module_name': [base, ...parts].join('/'),
          },
        );

        if (pkgVersResult case CRSErrorResponse(error: final err, statusCode: final statusCode)) {
          return CoreAdapterErrorResult(
            'bad request: $err',
            statusCode: statusCode ?? 404,
            responseType: ResponseType.plainText,
          );
        }

        final versions = pkgVersResult.body!.map((p) => 'v${p.version}');

        return CoreAdapterMetaResult(
          await versions.join('\n'),
          responseType: ResponseType.plainText,
        );
      } else if ([
            requestRequirements.replaceFirst(
              p.extension(requestRequirements),
              '',
            ),
            p.extension(requestRequirements).substring(1),
          ]
          case [String version, final String type]
          when Version.tryParse(
                version.startsWith('v') ? version.substring(1) : version,
              ) !=
              null) {
        version = version.startsWith('v') ? version.substring(1) : version;
        final pkgVerResult = await crs.getPackageWithVersion(
          scopedName(name, scope),
          version,
        );
        if (pkgVerResult case CRSErrorResponse(error: final err, statusCode: final statusCode)) {
          return CoreAdapterErrorResult(
            'bad request: $err',
            statusCode: statusCode ?? 404,
            responseType: ResponseType.plainText,
          );
        }

        switch (type) {
          case 'info':
            // get name and pub
            final pkgVerResult = await crs.getPackageWithVersion(
              scopedName(name, scope),
              version,
            );
            if (!pkgVerResult.isSuccess) {}
            final metaResult = {
              'Version': 'v$version',
              'Time': pkgVerResult.body!.created.toIso8601String(),
            };
            return CoreAdapterMetaResult(
              metaResult,
              responseType: ResponseType.json,
            );
          case 'mod':
            return CoreAdapterMetaResult(
              pkgVerResult.body!.config,
              responseType: ResponseType.plainText,
            );
          default:
            return CoreAdapterErrorResult(
              'bad request: unexpected extension "$type"',
              statusCode: 404,
              responseType: ResponseType.plainText,
            );
        }
      } else {
        return CoreAdapterErrorResult(
          'not found: $requestRequirements is a known non-module',
          responseType: ResponseType.plainText,
        );
      }
    }
    return CoreAdapterErrorResult(
      'bad request',
      statusCode: 404,
      responseType: ResponseType.plainText,
    );
  },
  retrieve: (req, crs) async {
    final segments = req.resolveObject.pathSegments;
    final positionOfAtV = segments.indexOf('@v');

    assert(positionOfAtV != -1);

    final [base, ...parts] = segments.sublist(0, positionOfAtV);
    final requestRequirements = segments.sublist(positionOfAtV + 1).first;

    assert(
      requestRequirements.toLowerCase().endsWith('.zip'),
      "Route meant for archive, should be <version>.zip",
    );

    // get name
    final (name, scope) = switch (parts) {
      [String name] => (name, null),
      [String scope, String name] => (name, scope),
      _ => (parts.last, parts.first == parts.last ? null : parts.first),
    };

    var version = requestRequirements.replaceFirst(
      p.extension(requestRequirements),
      '',
    );
    version = version.startsWith('v') ? version.substring(1) : version;

    final moduleName = [base, ...parts].join('/');
    final archiveResult = await crs.getArchiveWithVersion(
      scopedName(name, scope),
      version,
      env: {'module_name': moduleName},
    );

    if (!archiveResult.isSuccess) {
      return CoreAdapterErrorResult(
        'bad request: could not find archive for $moduleName',
        statusCode: 404,
        responseType: ResponseType.plainText,
      );
    }
    final archive = TarDecoder().decodeBytes(
      GZipDecoder().decodeBytes(
        await ByteStream(archiveResult.body!.data).toBytes(),
      ),
    );

    print(archive.length);
    print(archive.map((a) => a.name));

    final Archive outArchive = Archive();

    for (final archiveFile in archive) {
      outArchive.addFile(
        ArchiveFile(
          [
            base,
            if (scope case final s?) s,
            '$name@v$version',
            // name,
            archiveFile.name,
          ].join('/'),
          archiveFile.size,
          archiveFile.content,
          archiveFile.compressionType,
        ),
      );
    }

    final zipArchive = ZipEncoder().encode(outArchive);
    return CoreAdapterArchiveResult(
      ByteStream.fromBytes(zipArchive ?? []),
      '$moduleName@$version',
      contentType: 'application/zip',
    );
  },
);
