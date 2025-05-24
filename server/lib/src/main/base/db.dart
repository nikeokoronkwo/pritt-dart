// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:postgres/postgres.dart';
import 'package:pritt_server/src/main/crs/exceptions.dart';

import '../utils/version.dart';
import 'db/interface.dart';
import 'db/schema.dart';

/// The current implementation of the CRS Database makes use of [postgresql](https://www.postgresql.org/)
/// via the [postgres](https://pub.dev/packages/postgres) package
///
/// It uses a connection Pool to handle multiple requests
///
/// For more information on the APIs used in this class, see [PrittDatabaseInterface]
class PrittDatabase with SQLDatabase implements PrittDatabaseInterface {
  final Pool _pool;

  /// prepared statements
  final Map<String, Statement> _statements = {};

  PrittDatabase._({required Pool pool}) : _pool = pool;

  // TODO: Find a better singleton way of doing these db calls
  static PrittDatabase? db;
  static int dbConnections = 0;

  Future<void> disconnect() async {
    await _pool.close();
    for (var statement in _statements.values) {
      await statement.dispose();
    }
    dbConnections--;
  }

  static _preparePool(Pool pool) {
    // prepare pool with statements
  }

  static PrittDatabase connect({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
    bool devMode = false,
  }) {
    if (db == null) {
      final pool = Pool.withEndpoints([
        Endpoint(
            host: host,
            database: database,
            username: username,
            password: password,
            port: port)
      ],
          settings: devMode
              ? PoolSettings(maxConnectionCount: 20, sslMode: SslMode.disable)
              : PoolSettings(
                  maxConnectionCount: 20,
                ));

      _preparePool(pool);

      db = PrittDatabase._(pool: pool);
    }
    dbConnections++;

    return db!;
  }

  /// Execute basic SQL statements
  @override
  Future<Iterable<Map<String, dynamic>>> sql(String sql) async {
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
  Future<Iterable<PackageVersions>> getAllVersionsOfPackage(String name,
      {Package? package}) async {
    // less cacheable
    if (_statements['getAllVersionsOfPackage'] == null) {
      _statements['getAllVersionsOfPackage'] = await _pool.prepare('''
SELECT version, version_type, created_at, info, env, metadata, archive, hash, signatures, integrity, readme, config, config_name,
       deprecated, deprecated_message, yanked
FROM package_versions
WHERE package_id = (SELECT id FROM packages WHERE name = @name LIMIT 1)
''');
    }

    final result = await _statements['getAllVersionsOfPackage']!.run([name]);

    package ??= await getPackage(name);

    return result.map((row) {
      final columnMap = row.toColumnMap();
      return PackageVersions(
        package: package!,
        version: columnMap['version'] as String,
        versionType:
            VersionType.fromString(columnMap['version_type'] as String),
        created: columnMap['created_at'] as DateTime,
        info: columnMap['info'] as Map<String, dynamic>,
        env: columnMap['env'] as Map<String, String>,
        metadata: columnMap['metadata'] as Map<String, dynamic>,
        archive: Uri.file(columnMap['archive'] as String),
        hash: columnMap['hash'] as String,
        signatures: (columnMap['signatures'] as List<Map<String, dynamic>>)
            .map((e) => Signature.fromJson(e))
            .toList(),
        integrity: columnMap['integrity'] as String,
        readme: columnMap['readme'] as String?,
        config: columnMap['config'] as String?,
        configName: columnMap['config_name'] as String?,
        isDeprecated: columnMap['deprecated'] as bool,
        isYanked: columnMap['yanked'] as bool,
        deprecationMessage: columnMap['deprecated_message'] as String,
      );
    });
  }

  @override
  Future<Package> getPackage(String name, {String? language}) async {
    // cacheable
    if (language != null) {
      throw CRSException(CRSExceptionType.UNSUPPORTED_FEATURE,
          'Language filtering is not supported in this implementation');
    }

    if (_statements['getPackage'] == null) {
      _statements['getPackage'] = await _pool.prepare(Sql.named('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.description, p.license,
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name
'''));
    }
    final result = await _statements['getPackage']!.run({
      'name': name,
    });

    if (result.isEmpty) {
      throw CRSException(
          CRSExceptionType.PACKAGE_NOT_FOUND, 'Could not find package $name');
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
        description: columnMap['description'] as String?,
        license: columnMap['license'] as String?);
  }

  @override
  FutureOr<int> getPackagesCount() {
    // TODO: implement getPackagesCount
    throw UnimplementedError('TODO: implement getPackagesCount');
  }

  @override
  Future<int> getPackagesCountEstimate() async {
    if (_statements['getPackageCount'] == null) {
      _statements['getPackageCount'] = await _pool.prepare('''
SELECT reltuples::bigint AS estimate FROM pg_class where relname = 'packages';
''');
    }

    final result = await _statements['getPackageCount']!.run([]);
    return result.first.toColumnMap()['estimate'];
  }

  @override
  Future<Iterable<Package>> getPackages() async {
    // less cacheable
    if (_statements['getPackages'] == null) {
      _statements['getPackages'] = await _pool.prepare('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.description, p.license,
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
          description: columnMap['description'] as String?,
          license: columnMap['license'] as String?);
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
  Future<Iterable<User>> getUsers() async {
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
  FutureOr<PackageVersions> getPackageWithVersion(
      String name, Version version) async {
    // cacheable
    if (_statements['getPackageWithVersion'] == null) {
      _statements['getPackageWithVersion'] = await _pool.prepare(Sql.named('''
SELECT pv.version, pv.version_type, pv.created_at, pv.info, pv.env, pv.metadata, pv.archive, 
       pv.hash, pv.signatures, pv.integrity, pv.readme, pv.config, pv.config_name, 
       pv.deprecated, pv.deprecated_message, pv.yanked, 
       p.id as package_id, p.name as package_name, p.language as package_language, p.created_at as package_created_at, 
       p.updated_at as package_updated_at, p.version as package_latest_version, p.vcs as package_vcs, p.archive as package_archive,
       p.description as package_description, p.license as package_license,
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, 
       u.access_token_expires_at, u.created_at as author_created_at, 
       u.updated_at as author_updated_at
FROM package_versions pv
INNER JOIN packages p ON pv.package_id = p.id
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name AND pv.version = @version
LIMIT 1
'''));
    }
    final result = await _statements['getPackageWithVersion']!.run({
      'name': name,
      'version': version.toString(),
    });

    if (result.isEmpty) {
      throw CRSException(CRSExceptionType.VERSION_NOT_FOUND,
          'Could not find package $name with version $version');
    }

    final row = result.first;
    final columnMap = row.toColumnMap();
    return PackageVersions(
      package: Package(
          id: columnMap['package_id'] as String,
          version: columnMap['package_latest_version'] as String,
          name: name,
          author: User(
            id: columnMap['author_id'] as String,
            name: columnMap['author_name'] as String,
            accessToken: columnMap['access_token'] as String,
            accessTokenExpiresAt:
                columnMap['access_token_expires_at'] as DateTime,
            email: columnMap['author_email'] as String,
            createdAt: columnMap['author_created_at'] as DateTime,
            updatedAt: columnMap['author_updated_at'] as DateTime,
          ),
          language: columnMap['package_language'] as String,
          created: columnMap['package_created_at'] as DateTime,
          updated: columnMap['package_updated_at'] as DateTime,
          vcs: VCS.fromString(columnMap['package_vcs'] as String),
          archive: Uri.directory(columnMap['package_archive'] as String),
          description: columnMap['package_description'] as String?,
          license: columnMap['package_license'] as String?),
      version: version.toString(),
      versionType: VersionType.fromString(columnMap['version_type'] as String),
      created: columnMap['created_at'] as DateTime,
      info: columnMap['info'] as Map<String, dynamic>,
      env: columnMap['env'] as Map<String, String>,
      metadata: columnMap['metadata'] as Map<String, dynamic>,
      archive: Uri.file(columnMap['archive'] as String),
      hash: columnMap['hash'] as String,
      signatures: (columnMap['signatures'] as List<Map<String, dynamic>>)
          .map((e) => Signature.fromJson(e))
          .toList(),
      integrity: columnMap['integrity'] as String,
      readme: columnMap['readme'] as String?,
      config: columnMap['config'] as String?,
      configName: columnMap['config_name'] as String?,
      isDeprecated: columnMap['deprecated'] as bool,
      isYanked: columnMap['yanked'] as bool,
      deprecationMessage: columnMap['deprecated_message'] as String?,
    );
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
  FutureOr<Map<User, Iterable<Privileges>>> getContributorsForPackage(
      String name) async {
    // not cacheable

    final result = await _pool.execute(Sql.named('''
SELECT u.id, u.name, u.email, u.access_token, u.access_token_expires_at, u.created_at, u.updated_at,
       pc.package_id as package_id, pc.privileges as privileges
FROM package_contributors pc
LEFT JOIN users u ON pc.contributor_id = u.id
WHERE pc.package_id = (SELECT id FROM packages WHERE name = @name LIMIT 1)
'''), parameters: {
      'name': name,
    });

    return result.asMap().map((k, row) {
      final columnMap = row.toColumnMap();
      return MapEntry(
          User(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            email: columnMap['email'] as String,
            accessToken: columnMap['access_token'] as String,
            accessTokenExpiresAt:
                columnMap['access_token_expires_at'] as DateTime,
            createdAt: columnMap['created_at'] as DateTime,
            updatedAt: columnMap['updated_at'] as DateTime,
          ),
          (columnMap['privileges'] as Iterable<String>)
              .map((p) => Privileges.fromString(p)));
    });
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
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.license, p.description,
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
                  description: columnMap['description'] as String?,
                  license: columnMap['license'] as String?);
            })));
  }

  @override
  Stream<User> getUsersStream() async* {
    // less cacheable
    if (_statements['getUsers'] == null) {
      _statements['getUsers'] = await _pool.prepare('''
SELECT id, name, email, access_token, access_token_expires_at, created_at, updated_at
FROM users
''');
    }
    final result = _statements['getUsers']!.run([]);

    yield* Stream.fromFuture(result)
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

  @override
  FutureOr<Plugin> getPlugin(String id) {
    // TODO: implement getPlugin
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPluginsByLanguage(String language) {
    // TODO: implement getPluginsByLanguage
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPluginsForLanguages(Set<String> languages) {
    // TODO: implement getPluginsForLanguages
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Plugin>> getPlugins() async {
    // cacheable
    if (_statements['getPlugins'] == null) {
      _statements['getPlugins'] = await _pool.prepare('''
SELECT p.id, p.name, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.license, p.description,
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
''');
    }
    // TODO: implement getPlugins
    throw UnimplementedError();
  }
}

extension Authorization on PrittDatabase {
  /// Check for the authorization of a user
  /// TODO: Implement a better way to check for authorization, maybe put this behind a cache
  Future<User?> checkAuthorization(String accessToken) async {
    final result = await _pool.execute(Sql.named('''
SELECT id, name, email, access_token, access_token_expires_at, created_at, updated_at
FROM users
WHERE access_token = @accessToken
'''), parameters: {
      'accessToken': accessToken,
    });

    if (result.isEmpty) {
      throw UnauthorizedException('Invalid access token');
    }

    final row = result.first;
    final columnMap = row.toColumnMap();

    final expirationTime = columnMap['access_token_expires_at'] as DateTime;
    if (expirationTime.isBefore(DateTime.now())) {
      throw ExpiredTokenException('Access token has expired',
          token: accessToken);
    }

    final user = User(
      id: columnMap['id'] as String,
      name: columnMap['name'] as String,
      email: columnMap['email'] as String,
      accessToken: columnMap['access_token'] as String,
      accessTokenExpiresAt: columnMap['access_token_expires_at'] as DateTime,
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
    );

    return user;
  }
}
