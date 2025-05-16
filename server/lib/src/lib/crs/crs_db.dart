// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/shared/version.dart';

/// The current implementation of the CRS Database makes use of [postgresql](https://www.postgresql.org/)
/// via the [postgres](https://pub.dev/packages/postgres) package
///
/// It uses a connection Pool to handle multiple requests
///
/// For more information on the APIs used in this class, see [CRSDatabaseInterface]
class CRSDatabase implements CRSDatabaseInterface {
  final Pool _pool;
  final String url;

  /// prepared statements
  final Map<String, Statement> _statements = {};

  CRSDatabase._({required Pool pool, required this.url}) : _pool = pool;

  Future<void> disconnect() async {
    await _pool.close();
    for (var statement in _statements.values) {
      await statement.dispose();
    }
  }

  static _preparePool(Pool pool) {
    // prepare pool with statements
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

    _preparePool(pool);

    final url = 'postgres://$username:$password@$host:$port/$database';

    return CRSDatabase._(pool: pool, url: url);
  }

  /// Execute basic SQL statements
  Future<Iterable<Map<String, dynamic>>> sqlExec(String sql) async {
    return (await _pool.execute(sql)).map((future) => future.toColumnMap());
  }

  @override
  FutureOr<Package> addNewPackage(
      {required String name,
      required String version,
      required User author,
      required String language,
      required VCS vcs,
      Uri? archive,
      Iterable<User>? contributors}) {
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> addNewVersionOfPackage(
      {required String name,
      required String version,
      required User author,
      required String language,
      required VCS vcs,
      Uri? archive,
      Iterable<User>? contributors}) {
    // TODO: implement addNewVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<User> createUser({required String name, required String email}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> deprecateVersionOfPackage(
      String name, Version version) {
    // TODO: implement deprecateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<PackageVersions>> getAllVersionsOfPackage(
      String name) async {
    // less cacheable
    if (_statements['getAllVersionsOfPackage'] == null) {
      _statements['getAllVersionsOfPackage'] = await _pool.prepare('''

''');
    }

    final result = await _statements['getAllVersionsOfPackage']!.run([name]);

    // TODO: implement getAllVersionsOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> getPackage(String name) async {
    // cacheable
    if (_statements['getPackage'] == null) {
      _statements['getPackage'] = await _pool.prepare('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, 
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name
''');
    }
    final result = await _statements['getPackage']!.run([name]);
    if (result.isEmpty) {
      throw Exception('Package not found');
    }

    final row = result.first;
    final columnMap = row.toColumnMap();

    return Package(
      id: columnMap['id'] as String,
      name: columnMap['name'] as String,
      version: columnMap['version'] as String,
      author: User(
        id: columnMap['author_id'] as String,
        name: columnMap['author_name'] as String,
        email: columnMap['author_email'] as String,
        accessToken: columnMap['access_token'] as String,
        accessTokenExpiresAt: columnMap['access_token_expires_at'] as DateTime,
        createdAt: columnMap['author_created_at'] as DateTime,
        updatedAt: columnMap['author_updated_at'] as DateTime,
      ),
      language: columnMap['language'] as String,
      updated: columnMap['updated_at'] as DateTime,
      created: columnMap['created_at'] as DateTime,
      vcs: VCS.fromString(columnMap['updated_at'] as String),
      archive: Uri.directory(columnMap['archive'] as String),
    );
  }

  @override
  FutureOr<Iterable<Package>> getPackages() async {
    // less cacheable
    if (_statements['getPackages'] == null) {
      _statements['getPackages'] = await _pool.prepare('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, 
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
''');
    }

    final result = await _statements['getPackages']!.run([]);

    return result.map((row) {
      final columnMap = row.toColumnMap();
      return Package(
        id: columnMap['id'] as String,
        name: columnMap['name'] as String,
        version: columnMap['version'] as String,
        author: User(
          id: columnMap['author_id'] as String,
          name: columnMap['author_name'] as String,
          email: columnMap['author_email'] as String,
          accessToken: columnMap['access_token'] as String,
          accessTokenExpiresAt:
              columnMap['access_token_expires_at'] as DateTime,
          createdAt: columnMap['author_created_at'] as DateTime,
          updatedAt: columnMap['author_updated_at'] as DateTime,
        ),
        language: columnMap['language'] as String,
        updated: columnMap['updated_at'] as DateTime,
        created: columnMap['created_at'] as DateTime,
        vcs: VCS.fromString(columnMap['updated_at'] as String),
        archive: Uri.directory(columnMap['archive'] as String),
      );
    });
  }

  @override
  FutureOr<Iterable<Package>> getPackagesForUser(String id) {
    // cacheable

    // TODO: implement getPackagesForUser
    throw UnimplementedError();
  }

  @override
  FutureOr<User> getUser(String id) {
    // cacheable

    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  FutureOr<User> getUserByAccessToken(String accessToken) {
    // TODO: implement getUserByAccessToken
    throw UnimplementedError();
  }

  @override
  FutureOr<User> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<User>> getUsers() async {
    // less cacheable
    if (_statements['getUsers'] == null) {
      _statements['getUsers'] = await _pool.prepare('''
SELECT id, name, email, access_token, access_token_expires_at, created_at, updated_at
FROM users
''');
    }
    final result = await _statements['getUsers']!.run([]);

    return result.map((row) {
      final columnMap = row.toColumnMap();
      return User(
        id: columnMap['id'] as String,
        name: columnMap['name'] as String,
        email: columnMap['email'] as String,
        accessToken: columnMap['access_token'] as String,
        accessTokenExpiresAt: columnMap['access_token_expires_at'] as DateTime,
        createdAt: columnMap['created_at'] as DateTime,
        updatedAt: columnMap['updated_at'] as DateTime,
      );
    });
  }

  @override
  FutureOr<PackageVersions> getVersionOfPackage(String name, Version version) {
    // cacheable

    // TODO: implement getVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<User> setAccessTokenForUser(
      {required String id,
      required String accessToken,
      required DateTime expiresAt}) {
    // TODO: implement setAccessTokenForUser
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> updateNewPackageWithArchiveDetails(
      {required String name,
      required String version,
      required String hash,
      required String signature,
      required String integrity}) {
    // TODO: implement updateNewPackageWithArchiveDetails
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updatePackage(
      String name, Package Function(Package p1) updates) {
    // TODO: implement updatePackage
    throw UnimplementedError();
  }

  @override
  FutureOr<User> updateUser(
      {required String name,
      required String email,
      User Function(User p1)? updates}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updateVersionOfPackage(String name, Version version,
      PackageVersions Function(PackageVersions p1) updates) {
    // TODO: implement updateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> yankVersionOfPackage(String name, Version version) {
    // TODO: implement yankVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<User>> getContributorsForPackage(String name) {
    // TODO: implement getContributorsForPackage
    throw UnimplementedError();
  }

  // STREAMS

  @override
  Stream<PackageVersions> getAllVersionsOfPackageStream(String name) {
    // TODO: implement getAllVersionsOfPackageStream
    throw UnimplementedError();
  }

  @override
  Stream<Package> getPackagesForUserStream(String id) {
    // TODO: implement getPackagesForUserStream
    throw UnimplementedError();
  }

  @override
  Stream<Package> getPackagesStream() async* {
    // less cacheable
    if (_statements['getPackages'] == null) {
      _statements['getPackages'] = await _pool.prepare('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, 
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
''');
    }
    final result = _statements['getPackages']!.run([]);

    yield* Stream.fromFuture(result)
        .asyncExpand((e) => Stream.fromIterable(e.map((row) {
              final columnMap = row.toColumnMap();
              return Package(
                id: columnMap['id'] as String,
                name: columnMap['name'] as String,
                version: columnMap['version'] as String,
                author: User(
                  id: columnMap['author_id'] as String,
                  name: columnMap['author_name'] as String,
                  email: columnMap['author_email'] as String,
                  accessToken: columnMap['access_token'] as String,
                  accessTokenExpiresAt:
                      columnMap['access_token_expires_at'] as DateTime,
                  createdAt: columnMap['author_created_at'] as DateTime,
                  updatedAt: columnMap['author_updated_at'] as DateTime,
                ),
                language: columnMap['language'] as String,
                updated: columnMap['updated_at'] as DateTime,
                created: columnMap['created_at'] as DateTime,
                vcs: VCS.fromString(columnMap['updated_at'] as String),
                archive: Uri.directory(columnMap['archive'] as String),
              );
            })));
  }

  @override
  Stream<User> getUsersStream() {
    // less cacheable
    if (_statements['getUsers'] == null) {
      _statements['getUsers'] = await _pool.prepare('''
SELECT id, name, email, access_token, access_token_expires_at, created_at, updated_at
FROM users
''');
    }
    final result = _statements['getUsers']!.run([]);

    return Stream.fromFuture(result)
        .asyncExpand((e) => Stream.fromIterable(e.map((row) {
              final columnMap = row.toColumnMap();
              return User(
                id: columnMap['id'] as String,
                name: columnMap['name'] as String,
                email: columnMap['email'] as String,
                accessToken: columnMap['access_token'] as String,
                accessTokenExpiresAt:
                    columnMap['access_token_expires_at'] as DateTime,
                createdAt: columnMap['created_at'] as DateTime,
                updatedAt: columnMap['updated_at'] as DateTime,
              );
            })));
  }

  @override
  Stream<User> getContributorsForPackageStream(String name) {
    // TODO: implement getContributorsForPackageStream
    throw UnimplementedError();
  }
}
