// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:slugid/slugid.dart';
import 'package:crypto/crypto.dart';

import '../crs/exceptions.dart';
import '../utils/version.dart';

import 'auth.dart';
import 'db/annotations/cache.dart';
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
  final PrittAuth auth;

  /// prepared statements
  final Map<String, Statement> _statements = {};

  PrittDatabase._({required Pool pool})
      : _pool = pool,
        auth = PrittAuth();

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

  static Future<PrittDatabase> connect({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
    bool devMode = false,
  }) async {
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

  /// Update the authentication credentials for a user
  Future updateUserCredentials(
      String id, String name, String email, String accessToken) async {}

  /// Execute basic SQL statements
  @override
  Future<Iterable<Map<String, dynamic>>> sql(String sql) async {
    return (await _pool.execute(sql)).map((future) => future.toColumnMap());
  }

  @override
  FutureOr<(User, String)> createUser(
      {required String name, required String email}) async {
    final id = Slugid.nice();
    final createdAt = DateTime.now();
    final accessTokenExpiresAt = createdAt.add(Duration(days: 10));
    final (key: accessToken, hash: accessTokenHash) = auth.createAccessTokenForUser(
      name: name,
      email: email,
      expiresAt: accessTokenExpiresAt,
    );

    // TODO: Access Token Generation
    try {
      final result = await _pool.execute(r'''
INSERT INTO users (id, name, email, access_token, access_token_expires_at, created_at) 
VALUES ($1, $2, $3, $4, $5, $6) 
RETURNING *;''', parameters: [
        id,
        name,
        email,
        accessTokenHash,
        accessTokenExpiresAt,
        createdAt
      ]);

      final row = result.first;
      final columnMap = row.toColumnMap();

      return (User(
          id: columnMap['id'] as String,
          name: name,
          accessToken: accessTokenHash,
          accessTokenExpiresAt: accessTokenExpiresAt,
          email: email,
          createdAt: createdAt,
          updatedAt: columnMap['updated_at'] as DateTime), accessToken);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Iterable<PackageVersions>> getAllVersionsOfPackage(String name,
      {Package? package, String? scope}) async {
    // less cacheable
    if (_statements['getAllVersionsOfPackage'] == null) {
      _statements['getAllVersionsOfPackage'] = await _pool.prepare('''
SELECT version, version_type, created_at, info, env, metadata, archive, hash, signatures, integrity, readme, config, config_name,
       deprecated, deprecated_message, yanked
FROM package_versions
WHERE package_id = (SELECT id FROM packages WHERE name = @name AND scope = @scope LIMIT 1)
''');
    }

    final result = await _statements['getAllVersionsOfPackage']!.run({
      'name': name,
      'scope': scope,
    });

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
  Future<Package> getPackage(String name,
      {String? language, String? scope}) async {
    // cacheable
    if (language != null) {
      throw CRSException(CRSExceptionType.UNSUPPORTED_FEATURE,
          'Language filtering is not supported in this implementation');
    }

    if (_statements['getPackage'] == null) {
      _statements['getPackage'] = await _pool.prepare(Sql.named('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.vcs_url, p.archive, p.description, p.license,
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, u.access_token_expires_at, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name AND p.scope = @scope
'''));
    }
    final result = await _statements['getPackage']!.run({
      'name': name,
      'scope': scope,
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
        scope: columnMap['scope'] as String?,
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
        vcsUrl: columnMap['vcs_url'] != null
            ? Uri.parse(columnMap['vcs_url'] as String)
            : null,
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
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.vcs_url, p.archive, p.description, p.license,
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
          scope: columnMap['scope'] as String?,
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
          vcsUrl: columnMap['vcs_url'] != null
              ? Uri.parse(columnMap['vcs_url'] as String)
              : null,
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
  FutureOr<PackageVersions> getPackageWithVersion(String name, Version version,
      {String? scope}) async {
    // cacheable
    if (_statements['getPackageWithVersion'] == null) {
      _statements['getPackageWithVersion'] = await _pool.prepare(Sql.named('''
SELECT pv.version, pv.version_type, pv.created_at, pv.info, pv.env, pv.metadata, pv.archive, 
       pv.hash, pv.signatures, pv.integrity, pv.readme, pv.config, pv.config_name, 
       pv.deprecated, pv.deprecated_message, pv.yanked, 
       p.id as package_id, p.name as package_name, p.scope as package_scope, p.language as package_language, p.created_at as package_created_at, 
       p.updated_at as package_updated_at, p.version as package_latest_version, p.vcs as package_vcs, p.vcs_url as package_vcs_url, 
       p.archive as package_archive, p.description as package_description, p.license as package_license,
       u.id as author_id, u.name as author_name, u.email as author_email, u.access_token, 
       u.access_token_expires_at, u.created_at as author_created_at, 
       u.updated_at as author_updated_at
FROM package_versions pv
INNER JOIN packages p ON pv.package_id = p.id
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name AND pv.version = @version AND p.scope = @scope
LIMIT 1
'''));
    }
    final result = await _statements['getPackageWithVersion']!.run({
      'name': name,
      'version': version.toString(),
      'scope': scope,
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
          scope: columnMap['package_scope'] as String?,
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
          vcsUrl: columnMap['package_vcs_url'] != null
              ? Uri.parse(columnMap['package_vcs_url'] as String)
              : null,
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
  FutureOr<User> updateUser(
      {required String name,
      required String email,
      User Function(User p1)? updates}) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<User, Iterable<Privileges>>> getContributorsForPackage(
      String name,
      {String? scope}) async {
    // not cacheable

    final result = await _pool.execute(Sql.named('''
SELECT u.id, u.name, u.email, u.access_token, u.access_token_expires_at, u.created_at, u.updated_at,
       pc.package_id as package_id, pc.privileges as privileges
FROM package_contributors pc
LEFT JOIN users u ON pc.contributor_id = u.id
WHERE pc.package_id = (SELECT id FROM packages WHERE name = @name AND scope = @scope LIMIT 1)
'''), parameters: {
      'name': name,
      'scope': scope,
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
  Stream<Package> getPackagesForUserStream(String id) {
    // TODO: implement getPackagesForUserStream
    throw UnimplementedError();
  }

  @override
  Stream<Package> getPackagesStream() async* {
    // less cacheable
    if (_statements['getPackages'] == null) {
      _statements['getPackages'] = await _pool.prepare('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.license, p.description,
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
SELECT p.id, p.name, p.language, p.description, p.archive, p.archive_type
FROM plugins p
''');
    }

    final result = await _statements['getPlugins']!.run([]);

    return result.map((r) {
      final columnMap = r.toColumnMap();
      return Plugin(
          id: columnMap['id'] as String,
          name: columnMap['name'] as String,
          description: columnMap['description'] as String?,
          language: columnMap['language'] as String,
          archive: Uri.file(columnMap['archive'] as String),
          archiveType: switch (columnMap['archive_type'] as String) {
            'single' => PluginArchiveType.single,
            'multi' => PluginArchiveType.multi,
            _ => throw Exception(
                "Unknown Plugin Archive Type ${columnMap['archive_type']}")
          });
    });
  }

  @override
  FutureOr<Package> addContributorToPackage(
      String name, User user, Privileges privileges,
      {String? scope}) {
    // TODO: implement addContributorToPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopeUsers> addUserToOrganization(
      {required String organizationName,
      required User user,
      Iterable<Privileges> privileges = const []}) {
    // TODO: implement addUserToOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Scope> createOrganization(
      {required String name, String? description, required User owner}) {
    // TODO: implement createOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<User, Iterable<Privileges>>> getMembersForOrganization(
      String name) {
    // TODO: implement getMembersForOrganization
    throw UnimplementedError();
  }

  @override
  Stream<User> getMembersForOrganizationStream(String name) {
    // TODO: implement getMembersForOrganizationStream
    throw UnimplementedError();
  }

  @override
  FutureOr<Scope> getOrganizationByName(String name) {
    // TODO: implement getOrganizationByName
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Scope>> getOrganizations() {
    // TODO: implement getOrganizations
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Scope>> getOrganizationsForUser(String id) {
    // TODO: implement getOrganizationsForUser
    throw UnimplementedError();
  }

  @override
  Stream<Scope> getOrganizationsForUserStream(String id) {
    // TODO: implement getOrganizationsForUserStream
    throw UnimplementedError();
  }

  @override
  Stream<Scope> getOrganizationsStream() {
    // TODO: implement getOrganizationsStream
    throw UnimplementedError();
  }

  @override
  FutureOr<Iterable<Package>> getPackagesForOrganization(String name) {
    // TODO: implement getPackagesForOrganization
    throw UnimplementedError();
  }

  @override
  Stream<Package> getPackagesForOrganizationStream(String name) {
    // TODO: implement getPackagesForOrganizationStream
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopeUsers> removeUserFromOrganization(
      {required String organizationName, required User user}) {
    // TODO: implement removeUserFromOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Scope> updateOrganization(
      {required String name, Scope Function(Scope p1)? updates}) {
    // TODO: implement updateOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopeUsers> updateUserPrivilegesInOrganization(
      {required String organizationName,
      required User user,
      Iterable<Privileges> privileges = const []}) {
    // TODO: implement updateUserPrivilegesInOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> addNewPackage(
      {required String name,
      String? scope,
      String? description,
      required String version,
      required User author,
      required String language,
      required VCS vcs,
      Uri? archive,
      Iterable<User>? contributors}) {
    // TODO: implement addNewPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> addNewVersionOfPackage(
      {required String name,
      String? scope,
      required String version,
      String? description,
      required String hash,
      required String signature,
      required String integrity,
      String? readme,
      String? config,
      String? configName,
      Map<String, dynamic> info = const {},
      Map<String, String> env = const {},
      Map<String, dynamic> metadata = const {},
      required User author,
      required String language,
      required VCS vcs,
      Uri? archive,
      Iterable<User>? contributors}) {
    // TODO: implement addNewVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> deprecateVersionOfPackage(
      String name, Version version,
      {String? scope}) {
    // TODO: implement deprecateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  Stream<PackageVersions> getAllVersionsOfPackageStream(String name,
      {String? scope}) {
    // TODO: implement getAllVersionsOfPackageStream
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updatePackage(
      String name, Package Function(Package p1) updates,
      {String? scope}) {
    // TODO: implement updatePackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updateVersionOfPackage(String name, Version version,
      PackageVersions Function(PackageVersions p1) updates,
      {String? scope}) {
    // TODO: implement updateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> yankVersionOfPackage(String name, Version version,
      {String? scope}) {
    // TODO: implement yankVersionOfPackage
    throw UnimplementedError();
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> attachUserToAuthSession(
      {required String sessionId, required String userId, AuthorizationStatus? newStatus}) async {
    late Result result;

    await _pool.runTx((session) async {
      final rs = await session.execute(
          r'''SELECT expires_at, status FROM authorization_sessions WHERE session_id = $1''',
          parameters: [sessionId]);
      final expiresAt = rs[0][0] as DateTime;
      var status = AuthorizationStatus.fromString(rs[0][1] as String);
      if (expiresAt.isBefore(DateTime.now()) &&
          status == AuthorizationStatus.pending)
        status = AuthorizationStatus.expired;
      else if (newStatus != null) status = newStatus;

      result = await session.execute(r'''
        UPDATE authorization_sessions
        SET user_id = $1, status = $2
        WHERE session_id = $3
        RETURNING *
      ''', parameters: [userId, status.name, sessionId]);
    });

    final columnMap = result.first.toColumnMap();

    return AuthorizationSession(
        sessionId: sessionId,
        deviceId: columnMap['device_id'] as String,
        expiresAt: columnMap['expires_at'] as DateTime,
        userId: userId);
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> createNewAuthSession(
      {required String deviceId}) async {
    final enc = sha256.convert(utf8.encode(deviceId)).toString();
    final expiresAt = DateTime.now().add(Duration(hours: 1));

    final sessionId = Slugid(enc);

    final result = await _pool.execute(r'''
    INSERT INTO authorization_sessions (session_id, expires_at, device_id)
    VALUES ($1, $2, $3)
    RETURNING *
    ''', parameters: [sessionId.toString(), expiresAt, deviceId]);

    final row = result.first;
    final columnMap = row.toColumnMap();

    return AuthorizationSession(
        sessionId: sessionId.toString(),
        deviceId: deviceId,
        expiresAt: expiresAt);
  }

  @override
  @Cacheable()
  Future<AuthorizationStatus> getAuthSessionStatus(
      {required String sessionId}) async {
    final result = await _pool.execute(
        r'''SELECT status FROM authorization_sessions WHERE session_id = $1''',
        parameters: [sessionId]);

    return AuthorizationStatus.fromString(result[0][0] as String);
  }

  @override
  Future<(User, String)> updateUserAccessToken({required String id}) async {
    final updatedAt = DateTime.now();
    final accessTokenExpiresAt = updatedAt.add(Duration(days: 10));
    late String token;

    final result = await _pool.runTx((session) async {
      final userResult = await session.execute(r'''SELECT name, email FROM users WHERE id = $1''', parameters: [id]);

      final mainResult = userResult.first.toColumnMap();
      final (key: accessToken, hash: accessTokenHash) = auth.createAccessTokenForUser(
        name: mainResult['name'],
        email: mainResult['email'],
        expiresAt: accessTokenExpiresAt,
      );
      token = accessToken;
      return await session.execute(r'''
UPDATE users      
SET access_token = $1, access_token_expires_at = $2, updated_at = $3
WHERE id = $4
RETURNING *
      ''', parameters: [accessTokenHash, accessTokenExpiresAt, updatedAt, id]);

    });

    final columnMap = result.first.toColumnMap();

    return (User(
        id: columnMap['id'] as String,
        name: columnMap['name'] as String,
        accessToken: columnMap['access_token'] as String,
        accessTokenExpiresAt: accessTokenExpiresAt,
        email: columnMap['email'] as String,
        createdAt: columnMap['created_at'] as DateTime,
        updatedAt: updatedAt), token);
  }
}

extension Authorization on PrittDatabase {
  /// Check for the authorization of a user
  /// TODO: Implement a better way to check for authorization, maybe put this behind a cache
  Future<User?> checkAuthorization(
      String accessToken) async {
    bool noToken;

    // validate access token expiration
    if (accessToken.isEmpty) {
      throw UnauthorizedException('Access token is empty');
    }

    final result = await _pool.runTx((session) async {
      final rs = await session.execute(r'''SELECT access_token FROM users''');
      final accessTokenHashes = rs.map((row) => row[0] as String);
      final successFullToken = accessTokenHashes.where((hash) => auth.validateAccessToken(accessToken, hash));
      if (successFullToken.isEmpty) {
        noToken = true;
      } else if (successFullToken.singleOrNull == null) {
        noToken = false;
      } else {
        return await session.execute(Sql.named('''
SELECT id, name, email, access_token, access_token_expires_at, created_at, updated_at
FROM users
WHERE access_token = @accessToken'''), parameters: {
          'accessToken': successFullToken.first
        });
        noToken = false;
      }
    });

    if (result == null) throw UnauthorizedException('Invalid access token', token: accessToken);
    if (result.isEmpty) {
      throw UnauthorizedException('Invalid access token', token: accessToken);
    }

    final row = result.first;
    final columnMap = row.toColumnMap();

    // check the access token expiration
    // TODO: Double check other details
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
