import 'dart:convert';

import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';
import 'package:pritt_server/src/lib/adapter/core/npm/package_json.dart';
import 'package:pritt_server/src/lib/adapter/core/npm/result.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/utils/extensions.dart';

final npmAdapter = Adapter(
    id: 'npm',
    language: 'javascript',
    onResolve: (resolve) {
      if (resolve.userAgent.toString().containsAllOf(['npm', 'node'])) {
        if (resolve.path.endsWith('.tgz') ||
            resolve.path.endsWith('.tar.gz')) {
          return AdapterResolve.archive;
        } 
        return AdapterResolve.meta;
      }
      return AdapterResolve.none;
    },
    request: (req, crs) async {
      /// data needed from request
      /// 1. package name
      /// 
      /// data needed from crs
      /// 1. package info
      /// 2. package config
      /// 3. package archive path
      /// 4. all package versions
      /// 5. package hash
      
      // get the package name from the request
      final packageName = req.resolveObject.path
          .split('/')
          .last
          .replaceAll('.tgz', '')
          .replaceAll('.tar.gz', '');
      
      // get the package info from the crs
      final packageInfo = await crs.getPackageDetails(packageName);

      // get the latest package
      final latestPackage = await crs.getLatestPackage(packageName);

      // get the latest package npm config
      final latestPackageConfig = jsonDecode(latestPackage.body.config!);
      final latestPackageNpmConfig = PackageJson.fromJson(latestPackageConfig);

      // get all packages
      final allPackages = await crs.getPackages(packageName);

      // get package versions
      final packageVersions = allPackages.body.keys;

      return AdapterMetaResult(
        NpmMetaResult(
          id: packageName, 
          name: packageName, 
          // TODO: A faster and more conservative way rather than resorting a list multiple times
          distTags: NpmDistTags(
            latest: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.major).key.toString(),
            beta: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.beta).key.toString(),
            canary: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.canary).key.toString(),
            next: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.next).key.toString(),
            experimental: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.experimental).key.toString(),
            rc: allPackages.body.entries.firstWhere((e) => e.value.versionType == VersionType.rc).key.toString()
          ), 
          // TODO:
          versions: versions,
          maintainers: maintainers, time: time)
      )
      
    },
    retrieve: (req, crs) {

    });

class NpmUserAgentInfo {}
