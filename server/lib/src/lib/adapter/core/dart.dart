import 'dart:convert';

import 'package:path/path.dart';
import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';
import 'package:pritt_server/src/lib/adapter/core/dart/result.dart';
import 'package:yaml/yaml.dart';

final dartAdapter = Adapter(
    id: 'dart',
    language: 'dart',
    onResolve: (resolve) {
      if (resolve.userAgent.name == 'Dart pub') {
        if (resolve.path.startsWith('/api/packages')) {
          return AdapterResolve.meta;
        } else if (resolve.path.startsWith('/api/archives')) {
          return AdapterResolve.archive;
        }
      }
      return AdapterResolve.none;
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

      // get the latest version
      final latestVersion = packageDetails.body.version;

      // get all packages
      final packages = await crs.getPackages(packageName);
      final latestPackage = packages.body.values.firstWhere(
        (element) => element.version == latestVersion,
      );

      return AdapterMetaResult(
        DartMetaResult(
            name: packageName,
            latest: DartPackage(
                version: latestPackage.version,
                pubspec:
                    jsonDecode(jsonEncode(loadYaml(latestPackage.config!))),
                // TODO: Shouldn't we make this easier on ourselves and just use a /dart/ path to reduce guess work?
                archiveUrl:
                    '${req.resolveObject.url}/api/archives/${latestPackage.configName}-${latestPackage.version}.tar.gz',
                archiveHash: latestPackage.hash,
                published: latestPackage.created),
            versions: packages.body.values
                .map((e) => DartPackage(
                    version: e.version,
                    pubspec: jsonDecode(jsonEncode(loadYaml(e.config!))),
                    archiveUrl:
                        '${req.resolveObject.url}/api/archives/${e.configName}-${e.version}.tar.gz',
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
      final version = basenameWithoutExtension(versionAndExtension);
      final packageExtension = versionAndExtension.replaceFirst(version, '');

      // get the archive
      final archive = await crs.getArchiveWithVersion(packageName, version);

      // stream the archive
      return AdapterArchiveResult(
        archive.body.data,
        archive.body.name,
        contentType: archive.body.contentType ?? 'application/x-tar',
      );
    });
