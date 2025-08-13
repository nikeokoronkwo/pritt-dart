import 'dart:io';

import 'package:pritt_common/functions.dart';
import 'package:pritt_common/version.dart';
import 'package:pritt_server_core/pritt_server_core.dart';

import '../adapter.dart';
import '../adapter/base_result.dart';
import '../adapter/resolve.dart';
import '../adapter/result.dart';
import 'swift/error.dart';
import 'swift/responses.dart';

final swiftAdapter = Adapter(
  id: 'swift',
  language: 'swift',
  resolve: (resolve) {
    if (resolve.userAgent.toString().contains('SwiftPackageManager')) {
      if (resolve.path.endsWith('.zip') ||
          resolve.path.contains('Package.swift?swift-version')) {
        return AdapterResolveType.archive;
      }
      return AdapterResolveType.meta;
    }
    return AdapterResolveType.none;
  },
  request: (req, crs) async {
    if (req.resolveObject.pathSegments case ['identifiers']) {
      // search for identifiers
      // TODO: Support package searching
    }
    // get package name and scope
    final [virtualScope, name] = req.resolveObject.pathSegments;
    final rest = req.resolveObject.pathSegments.skip(2);

    final scope = virtualScope == 'pritt' ? null : virtualScope;
    final pkgScopedName = scopedName(name, scope);

    // get the package info from the crs
    final packageInfo = await crs.getPackageDetails(pkgScopedName);

    // check if the package info is successful
    // if not, return an error
    if (packageInfo case CRSErrorResponse(
      error: final err,
      statusCode: final statusCode,
    )) {
      return CoreAdapterErrorResult<SwiftError>(
        SwiftError(detail: err),
        statusCode: statusCode ?? 500,
      );
    }

    final CRSSuccessResponse(body: packageDetails) = packageInfo.asSuccess;

    switch (rest) {
      case []:
        // get package versions
        final CRSSuccessResponse(body: packageVersionsStream) = crs
            .getPackagesStream(pkgScopedName)
            .asSuccess;

        return CoreAdapterMetaJsonResult(
          headers: {
            if (packageDetails.vcsUrl case final vcsLink?)
              'Link': '<${vcsLink.toString()}>; rel="canonical"',
          },
          SwiftPackageResponse(
            releases: (await packageVersionsStream.map((ver) {
              return (
                ver.version,
                SwiftRelease(
                  uri: Uri.parse(
                    '${req.resolveObject.url}/$virtualScope/$name/${ver.version}',
                  ),
                  problem: ver.isYanked || ver.isDeprecated
                      ? SwiftError(
                          detail:
                              'This package has been ${ver.isYanked ? 'yanked' : 'deprecated'} from the registry.',
                          title: ver.isYanked ? 'Gone' : 'Deprecated',
                          status: 410,
                        )
                      : null,
                ),
              );
            }).toList()).asMap().map((_, record) => MapEntry(record.$1, record.$2)),
          ),
        );
      case [final String version] when Version.tryParse(version) != null:
        final result = await crs.getPackageWithVersion(pkgScopedName, version);
        if (result case CRSErrorResponse(error: final error)) {
          return CoreAdapterErrorJsonResult(
            SwiftError(detail: error),
            statusCode: 404,
          );
        }
        final CRSSuccessResponse(body: pkgVer) = result.asSuccess;
        final CRSSuccessResponse(body: packageVersionsResult) =
            (await crs.getPackages(pkgScopedName)).asSuccess;
        final versions = packageVersionsResult.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        final baseGetPkgUrl = '${req.resolveObject.url}/$virtualScope/$name';

        final latestVersion = versions.last;
        final currentVersionIndex = versions.indexWhere(
          (element) => element.toString() == version,
        );
        final nextVersion = currentVersionIndex == versions.length - 1
            ? null
            : versions[currentVersionIndex + 1];
        final prevVersion = currentVersionIndex == 0
            ? null
            : versions[currentVersionIndex - 1];

        return CoreAdapterMetaJsonResult(
          SwiftPackage(
            id: '$virtualScope.$name',
            version: version,
            publishedAt: pkgVer.created,
            resources: [
              SwiftResource(
                // FIXME: Invalid checksum - needs zip checksum
                checksum: pkgVer.hash,
              ),
            ],
          ),
          headers: {
            'Link': [
              '<$baseGetPkgUrl/$latestVersion>; rel="latest-version"',
              if (nextVersion case final next?)
                '<$baseGetPkgUrl/$next>; rel="successor-version"',
              if (prevVersion case final prev?)
                '<$baseGetPkgUrl/$prev>; rel="predecessor-version"',
            ].join(','),
          },
        );
      case [final String version, 'Package.swift']
          when Version.tryParse(version) != null &&
              req.resolveObject.query.containsKey('swift-version'):
        final baseGetPkgUrl = '${req.resolveObject.url}/$virtualScope/$name';

        // TODO(nikeokoronkwo): Support swift-version Package.swift
        return CoreAdapterErrorResult(
          null,
          statusCode: 303,
          headers: {
            HttpHeaders.locationHeader: '$baseGetPkgUrl/$version/Package.swift',
          },
        );
      case [final String version, 'Package.swift']
          when Version.tryParse(version) != null:
        final result = await crs.getPackageWithVersion(pkgScopedName, version);
        if (result case CRSErrorResponse(error: final error)) {
          return CoreAdapterErrorJsonResult(
            SwiftError(detail: error),
            statusCode: 404,
          );
        }
        final CRSSuccessResponse(body: pkgVer) = result.asSuccess;

        return CoreAdapterMetaResult(
          pkgVer.config,
          responseType: ResponseTypeBase('text/x-swift'),
          headers: {
            HttpHeaders.contentDisposition:
                'attachment; filename="Package.swift"',
            HttpHeaders.contentLengthHeader: pkgVer.config?.length.toString(),
          },
        );
      
      default:
        return CoreAdapterErrorJsonResult(
          SwiftError(detail: 'Unknown route ${req.resolveObject.url}'),
          responseType: ResponseTypeBase('application/problem+json'),
        );
    }
  },
  retrieve: (req, crs) async {
    // TODO: They accept ZIP.
    throw UnimplementedError();
  },
);
