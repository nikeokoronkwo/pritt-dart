// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:pritt_common/functions.dart';
import 'package:pritt_common/version.dart';

import '../base/db.dart';
import '../base/db/interface.dart';
import '../base/db/schema.dart';
import '../base/storage.dart';
import '../base/storage/interface.dart';
import 'exceptions.dart';
import 'interfaces.dart';
import 'response.dart';

class CoreRegistryServiceController implements CRSController {
  CoreRegistryService delegate;
  String language;

  /// Creates a new instance of the core registry service controller
  CoreRegistryServiceController(this.delegate, this.language);

  @override
  PrittDatabaseInterface get db => delegate.db;

  @override
  Future<CRSResponse<CRSArchive>> getArchiveWithVersion(
          String packageName, String version,
          {String? language, Map<String, dynamic>? env}) =>
      delegate.getArchiveWithVersion(packageName, version,
          language: this.language, env: env);

  @override
  Future<CRSResponse<PackageVersions>> getLatestPackage(String packageName,
          {String? language, Map<String, dynamic>? env}) =>
      delegate.getLatestPackage(packageName, language: this.language, env: env);

  @override
  Future<CRSResponse<Package>> getPackageDetails(String packageName,
          {String? language, Map<String, dynamic>? env}) =>
      delegate.getPackageDetails(packageName,
          language: this.language, env: env);

  @override
  Future<CRSResponse<PackageVersions>> getPackageWithVersion(
          String packageName, String version,
          {String? language, Map<String, dynamic>? env}) =>
      delegate.getPackageWithVersion(packageName, version,
          language: this.language, env: env);

  @override
  Future<CRSResponse<Map<Version, PackageVersions>>> getPackages(
          String packageName,
          {String? language,
          Map<String, dynamic>? env}) =>
      delegate.getPackages(packageName, language: this.language, env: env);

  @override
  CRSResponse<Stream<PackageVersions>> getPackagesStream(String packageName,
          {String? language, Map<String, dynamic>? env}) =>
      delegate.getPackagesStream(packageName,
          language: this.language, env: env);

  @override
  PrittStorageInterface get ofs => delegate.ofs;

  @override
  Future<CRSResponse<Map<User, Iterable<Privileges>>>> getPackageContributors(
          String packageName,
          {String? language,
          Map<String, dynamic>? env}) =>
      delegate.getPackageContributors(packageName,
          language: this.language, env: env);

  @override
  FutureOr setFileServer(String packageName,
          {String? version, String? language, bool cache = false}) =>
      delegate.setFileServer(packageName,
          version: version, language: this.language, cache: cache);
}

/// The core registry service
///
/// This is a service that contains the package-manager agnostic (matter of fact, environment agnostic) info about packages in the Pritt Registry
///
/// It connects to the database and the object file storage via a pool of resources (i.e makes multiple concurrent requests capped at a maximum)
/// For now, we use a single connection to the database and a single connection to the object file storage
///
/// It directly inherits from the [CRSDBController] and [CRSArchiveController] interfaces
class CoreRegistryService implements CRSController {
  @override
  PrittDatabase db;

  @override
  PrittStorage ofs;

  CoreRegistryService._(this.db, this.ofs);

  CoreRegistryServiceController controller(String language) {
    return CoreRegistryServiceController(this, language);
  }

  /// Creates a new instance of the core registry service
  static Future<CoreRegistryService> connect(
      {PrittDatabase? db, PrittStorage? storage}) async {
    db ??= await PrittDatabase.connect(
      host: String.fromEnvironment('DATABASE_HOST'),
      port: int.fromEnvironment('DATABASE_PORT', defaultValue: 5432),
      database: String.fromEnvironment('DATABASE_NAME'),
      username: String.fromEnvironment('DATABASE_USERNAME'),
      password: String.fromEnvironment('DATABASE_PASSWORD'),
      devMode: String.fromEnvironment('DATABASE_HOST') == 'localhost',
    );

    storage ??= await PrittStorage.connect(String.fromEnvironment('S3_URL'));

    return CoreRegistryService._(db, storage);
  }

  Future<void> disconnect() async {
    await db.disconnect();
  }

  @override
  Future<CRSResponse<CRSArchive>> getArchiveWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final file = await ofs
          .getPackage('/${scope == null ? name : '$scope/$name'}/$version.tgz');
      final archive = CRSArchive(
        '$packageName.tar.gz',
        file.contentType ?? 'application/gzip',
        Stream.fromIterable([file.data]),
      );
      return CRSResponse.success(
        body: archive,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      switch (e.type) {
        case CRSExceptionType.OBJECT_NOT_FOUND:
          return CRSResponse.error(
            error: 'Package not found: ${e.message}',
            statusCode: 404,
          );
        default:
          return CRSResponse.error(
            error: 'An unknown error occurred',
            statusCode: 500,
          );
      }
    }
  }

  @override
  Future<CRSResponse<PackageVersions>> getLatestPackage(String packageName,
      {String? language, Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final package = await db.getPackage(name, scope: scope);
      final latestVersion = package.version;

      if (language != null && package.language != language) {
        return CRSResponse.error(
          error:
              'Package not found for the specified languag: $packageName is associated with ${package.language}',
          statusCode: 404,
        );
      }

      // TODO: Implement [db.getPackageWithVersion] method
      final latestPackage = await db.getPackageWithVersion(
          packageName, Version.parse(latestVersion));

      return CRSResponse.success(
        body: latestPackage,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      switch (e.type) {
        case CRSExceptionType.PACKAGE_NOT_FOUND:
          return CRSResponse.error(
            error: 'Package not found: ${e.message}',
            statusCode: 404,
          );
        case CRSExceptionType.VERSION_NOT_FOUND:
          return CRSResponse.error(
            error: 'Version not found: ${e.message}',
            statusCode: 404,
          );
        default:
          return CRSResponse.error(
            error: 'An unknown error occurred: ${e.message}',
            // use 501 to differentiate unknown errors from adapter registry (i.e unhandled) from other unknown errors (that use 500)
            statusCode: 501,
          );
      }
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<CRSResponse<Package>> getPackageDetails(String packageName,
      {String? language, Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final package = await db.getPackage(name, scope: scope);

      if (language != null && package.language != language) {
        return CRSResponse.error(
          error:
              'Package not found for the specified languag: $packageName is associated with ${package.language}',
          statusCode: 404,
        );
      }

      return CRSResponse.success(
        body: package,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      switch (e.type) {
        case CRSExceptionType.PACKAGE_NOT_FOUND:
          return CRSResponse.error(
            error: 'Package not found: ${e.message}',
            statusCode: 404,
          );
        default:
          return CRSResponse.error(
            error: 'An unknown error occurred: ${e.message}',
            statusCode: 501,
          );
      }
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<CRSResponse<PackageVersions>> getPackageWithVersion(
      String packageName, String version,
      {String? language, Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final pkg = await db.getPackageWithVersion(name, Version.parse(version),
          scope: scope);

      if (language != null && pkg.package.language != language) {
        return CRSResponse.error(
          error:
              'Package not found for the specified languag: $packageName is associated with ${pkg.package.language}',
          statusCode: 404,
        );
      }

      return CRSResponse.success(
        body: pkg,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      switch (e.type) {
        case CRSExceptionType.VERSION_NOT_FOUND:
          return CRSResponse.error(
            error: 'Package for specified version not found: ${e.message}',
            statusCode: 404,
          );
        default:
          return CRSResponse.error(
            error: 'An unknown error occurred: ${e.message}',
            statusCode: 501,
          );
      }
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<CRSResponse<Map<Version, PackageVersions>>> getPackages(
      String packageName,
      {String? language,
      Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final packages = await db.getAllVersionsOfPackage(name, scope: scope);

      if (language != null &&
          !packages.every((pkg) => pkg.package.language == language)) {
        return CRSResponse.error(
          error:
              'Package not found for the specified languag: $packageName is associated with ${packages.first.package.language}',
          statusCode: 404,
        );
      }

      return CRSResponse.success(
        body: packages
            .toList()
            .asMap()
            .map((k, v) => MapEntry(Version.parse(v.version), v)),
        statusCode: 200,
      );
    } on CRSException catch (e) {
      return CRSResponse.error(
        error: 'An unknown error occurred: ${e.message}',
        statusCode: 501,
      );
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  CRSResponse<Stream<PackageVersions>> getPackagesStream(String packageName,
      {String? language, Map<String, dynamic>? env}) {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final packages = db.getAllVersionsOfPackage(name, scope: scope);

      var pkgStream = Stream.fromFuture(packages)
          .asyncExpand((e) => Stream.fromIterable(e));

      return CRSResponse.success(
        body: pkgStream,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      return CRSResponse.error(
        error: 'An unknown error occurred: ${e.message}',
        statusCode: 501,
      );
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<CRSResponse<Map<User, Iterable<Privileges>>>> getPackageContributors(
      String packageName,
      {String? language,
      Map<String, dynamic>? env}) async {
    try {
      final (name, scope: scope) = parsePackageName(packageName);
      final contributors =
          await db.getContributorsForPackage(name, scope: scope);

      return CRSResponse.success(
        body: contributors,
        statusCode: 200,
      );
    } on CRSException catch (e) {
      return CRSResponse.error(
        error: 'An unknown error occurred: ${e.message}',
        statusCode: 501,
      );
    } catch (e) {
      // Handle any other exceptions that may occur
      return CRSResponse.error(
        error: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  FutureOr setFileServer(String packageName,
      {String? version, String? language, bool cache = false}) {
    // TODO: implement setFileServer
    throw UnimplementedError();
  }
}

class CRSDBOptions {}

class CRSOFSOptions {}
