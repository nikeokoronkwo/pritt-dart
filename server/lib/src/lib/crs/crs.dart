// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:postgres/postgres.dart';
import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/crs/fs.dart';

/// The current implementation of the CRS Database makes use of [postgresql](https://www.postgresql.org/)
/// via the [postgres](https://pub.dev/packages/postgres) package
///
/// It uses a connection Pool to handle multiple requests
///
/// For more information on the APIs used in this class, see [CRSDatabaseInterface]
class CRSDatabase implements CRSDatabaseInterface {
  final Pool _pool;
  final String url;

  CRSDatabase._({required Pool pool, required this.url}) : _pool = pool;

  Future<void> disconnect() async {
    _pool.close();
  }

  static CRSDatabase connect({
    String? host,
    String? database,
    String? username,
    String? password,
  }) {
    host ??= String.fromEnvironment('DATABASE_HOST');
    database ??= String.fromEnvironment('DATABASE_NAME');
    username ??= String.fromEnvironment('DATABASE_USERNAME');
    password ??= String.fromEnvironment('DATABASE_PASSWORD');
    final port = int.fromEnvironment('DATABASE_PORT', defaultValue: 5432);

    final pool = Pool.withEndpoints([
      Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port)
    ],
        settings: PoolSettings(
          maxConnectionCount: 20,
        ));

    final url = 'postgres://$username:$password@$host:$port/$database';

    return CRSDatabase._(pool: pool, url: url);
  }

  @override
  FutureOr<Package> addNewPackage() {
    // TODO: implement addNewPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> addNewVersionOfPackage() {
    // TODO: implement addNewVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> deprecateVersionOfPackage() {
    // TODO: implement deprecateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> getPackage() {
    // TODO: implement getPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> getVersionOfPackage() {
    // TODO: implement getVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updatePackage(Map<String, dynamic> updates) {
    // TODO: implement updatePackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updateVersionOfPackage(Map<String, dynamic> updates) {
    // TODO: implement updateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> yankVersionOfPackage() {
    // TODO: implement yankVersionOfPackage
    throw UnimplementedError();
  }
}

/// The current implementation of the CRS Object File Storage, used for storing package archives makes use of multiple backends, but basically make use of the [S3 API]().
/// During development, or docker compose deployments, we use [OpenIO]().
///
/// During live production deployments (usually not on prem), we make use of &lt;insert cloud provider S3 compatible OFS here&gt;
class CRSStorage implements CRSRegistryOFSInterface {
  CRSStorage._();

  S3 get s3Instance {
    if (CRSStorage.s3 != null) return CRSStorage.s3!;
    throw Exception('S3 not initialised');
  }

  static S3? s3;

  static S3 initialiseS3(
      {String? region, String? accessKey, String? secretKey}) {
    region ??= String.fromEnvironment('S3_REGION');
    secretKey ??= String.fromEnvironment('S3_SECRET_KEY');
    accessKey ??= String.fromEnvironment('S3_ACCESS_KEY');
    s3 = S3(
        region: 'us-east-1',
        credentials:
            AwsClientCredentials(accessKey: accessKey, secretKey: secretKey));

    return s3!;
  }

  static CRSStorage connect(
      {String? s3region, String? s3accessKey, String? s3secretKey}) {
    if (s3 == null) {
      initialiseS3(
          region: s3region, accessKey: s3accessKey, secretKey: s3secretKey);
    }

    return CRSStorage._();
  }

  @override
  FutureOr copy(String from, String to) {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  FutureOr create(String path, Uint8List data, String sha) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  FutureOr list(String path) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  FutureOr listAll() {
    // TODO: implement listAll
    throw UnimplementedError();
  }

  @override
  FutureOr listWhere(bool Function(String path) where) {
    // TODO: implement listWhere
    throw UnimplementedError();
  }

  @override
  FutureOr remove(String path) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  FutureOr update(String path, Uint8List data) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

/// The core registry service
///
/// This is a service that contains the package-manager agnostic (matter of fact, environment agnostic) info about packages in the Pritt Registry
///
/// It connects to the database and the object file storage via a pool of resources (i.e makes multiple concurrent requests capped at a maximum) and provides access to data in the
class CoreRegistryService {}
