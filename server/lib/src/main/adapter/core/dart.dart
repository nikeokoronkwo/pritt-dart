import 'dart:convert';

import 'package:path/path.dart';
import 'package:pritt_common/version.dart';
import 'package:yaml/yaml.dart';

import '../../base/db/schema.dart';
import '../../crs/response.dart';
import '../../utils/mixins.dart';
import '../adapter.dart';
import '../adapter/resolve.dart';
import '../adapter/result.dart';
import 'dart/pubspec.dart';
import 'dart/result.dart';

final dartAdapter = Adapter(
    id: 'dart',
    language: 'dart',
    resolve: (resolve) {
      if (resolve.userAgent.toString().contains('Dart pub')) {
        if (resolve.path.startsWith('/api/packages')) {
          return AdapterResolveType.meta;
        } else if (resolve.path.startsWith('/api/archives')) {
          return AdapterResolveType.archive;
        }
      }
      return AdapterResolveType.none;
    },

    /// we need to retrieve the package details
    /// 1. get the package name
    /// 2. get the version
    ///
    /// then we need to make a request to the registry
    /// 1. get the package name
    /// 2. get the latest package details
    /// 3. get a map of the package details
    request: (req, crs) async {
      // get the package name
      final packageName = req.resolveObject.path.split('/').last;

      // retrieve the package details
      final packageDetails = await crs.getPackageDetails(packageName);

      if (!packageDetails.isSuccess) {
        return AdapterErrorResult(
            DartErrorResult(
              code: 'NoSuchKey',
              message: 'The specified key does not exist.',
            ),
            statusCode: 404,
            responseType: ResponseType.xml);
      }

      // get the latest version
      final latestVersion = packageDetails.body!.version;

      // get all packages
      final packages = await crs.getPackages(packageName)
          as CRSSuccessResponse<Map<Version, PackageVersions>>;

      final latestPackage = packages.body.entries.firstWhere(
        (entry) => entry.key.toString() == latestVersion,
      ).value;

      return AdapterMetaJsonResult(
        contentType: 'application/vnd.pub.v2+json',
        DartMetaResult(
            name: packageName,
            latest: DartPackage(
                version: latestPackage.version,
                pubspec: PubSpec.fromJson(jsonDecode(jsonEncode(loadYaml(latestPackage.config!)))),
                // TODO: Shouldn't we make this easier on ourselves and just use a /dart/ path to reduce guess work?
                archiveUrl:
                    '${req.resolveObject.url}/api/archives/${latestPackage.configName}-${latestPackage.version}.tar.gz',
                archiveHash: latestPackage.hash,
                published: latestPackage.created),
            versions: packages.body.values
                .map((e) => DartPackage(
                    version: e.version,
                    pubspec: PubSpec.fromJson(jsonDecode(jsonEncode(loadYaml(e.config!)))),
                    archiveUrl:
                        '${req.resolveObject.url}/api/archives/${e.package.name}-${e.version}.tar.gz',
                    archiveHash: e.hash,
                    published: e.created))
                .toList()),
      );
    },
    retrieve: (req, crs) async {
      // get the name of the package
      final packageNameWithExtension = req.resolveObject.path.split('/').last;
      final [packageName, versionAndExtension] =
          packageNameWithExtension.split('-');
      final version = basenameWithoutExtension(basenameWithoutExtension(versionAndExtension));
      final _ = versionAndExtension.replaceFirst(version, '');

      // get the archive
      final archive = await crs.getArchiveWithVersion(packageName, version);

      if (!archive.isSuccess) {
        return AdapterErrorResult(
            DartErrorResult(
              code: 'NoSuchKey',
              message: 'The specified key does not exist.',
            ),
            statusCode: 404,
            responseType: ResponseType.xml);
      }

      // stream the archive
      return AdapterArchiveResult(
        archive.body!.data,
        archive.body!.name,
        contentType: archive.body!.contentType ?? 'application/gzip',
      );
    });

class DartErrorResult with JsonConvertible {
  final String code;
  final String message;

  DartErrorResult({required this.code, required this.message});

  @override
  Map<String, dynamic> toJson() => {
        'Code': code,
        'Message': message,
      };
}
