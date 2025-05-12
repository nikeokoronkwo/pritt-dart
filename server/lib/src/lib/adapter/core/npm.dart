import 'dart:convert';

import 'package:path/path.dart';
import 'package:pritt_server/src/lib/adapter/adapter.dart';
import 'package:pritt_server/src/lib/adapter/adapter_base.dart';
import 'package:pritt_server/src/lib/adapter/core/npm/package_json.dart';
import 'package:pritt_server/src/lib/adapter/core/npm/result.dart';
import 'package:pritt_server/src/lib/shared/version.dart';
import 'package:pritt_server/src/utils/extensions.dart';

final npmAdapter = Adapter(
    id: 'npm',
    language: 'javascript',
    onResolve: (resolve) {
      if (resolve.userAgent.toString().containsAllOf(['npm', 'node'])) {
        if (resolve.path.endsWith('.tgz') || resolve.path.endsWith('.tar.gz')) {
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

      final versionGroups = <VersionType, Version?>{
        for (var type in VersionType.values) type: null
      };

      for (final ver in packageVersions) {
        if (versionGroups.containsKey(ver.versionType)) {
          versionGroups[ver.versionType] =
              versionGroups[ver.versionType] == null
                  ? ver
                  : (versionGroups[ver.versionType]! > ver
                      ? versionGroups[ver.versionType]
                      : ver);
        }
      }

      return AdapterMetaResult(NpmMetaResult(
          id: packageName,
          name: packageName,
          distTags: NpmDistTags(
              latest: versionGroups[VersionType.major].toString(),
              beta: versionGroups[VersionType.beta].toString(),
              canary: versionGroups[VersionType.canary].toString(),
              // this one is iterating because npm's definition of a "next" version is not completely related to its prerelease info
              next: allPackages.body.entries
                  .firstWhere((e) =>
                      e.value.versionType == VersionType.next &&
                      e.key > Version.parse(latestPackage.body.version))
                  .key
                  .toString(),
              experimental: versionGroups[VersionType.experimental].toString(),
              rc: versionGroups[VersionType.rc].toString()),
          versions: allPackages.body.map((k, v) {
            return MapEntry(
                k.toString(),
                NpmPackage.fromPackageJson(
                    PackageJson.fromJson(jsonDecode(v.config!)),
                    id: "$packageName@${k.toString()}",
                    dist: NpmDist(
                        shasum: v.hash,
                        tarball:
                            '${req.resolveObject.url}/$packageName/-/$packageName-${v.version}.tar.gz',
                        integrity: v.integrity,
                        signatures: v.signatures.map((s) =>
                            {'keyid': s.publicKeyId, 'sig': s.signature})),
                    npmVersion: v.env['npmVersion'],
                    npmUser: v.env['npmUser']));
          }),
          maintainers: packageInfo.body.contributors
              .map((c) => {'name': c.name, 'email': c.emailAddress}),
          time: allPackages.body.map(
              (k, v) => MapEntry(k.toString(), v.created.toIso8601String()))));
    },
    retrieve: (req, crs) async {
      // get the name of the package
      final packageName = req.resolveObject.pathSegments[0];
      final packageFile = req.resolveObject.pathSegments.last;
      final [_, version] = packageFile
          .split('-')
          .map((e) => basenameWithoutExtension(e))
          .toList();

      final archive = await crs.getArchiveWithVersion(packageName, version);

      // stream the archive
      return AdapterArchiveResult(
        archive.body.data,
        archive.body.name,
        contentType: archive.body.contentType ?? 'application/x-tar',
      );
    });

class NpmUserAgentInfo {}
