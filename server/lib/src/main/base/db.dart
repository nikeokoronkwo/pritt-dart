// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  FutureOr<User> createUser(
      {required String name, required String email}) async {
    final id = Slugid.nice();

    // TODO: Access Token Generation
    try {
      final result = await _pool.execute(r'''
INSERT INTO users (id, name, email) 
VALUES ($1, $2, $3) 
RETURNING *''', parameters: [id, name, email]);

      final row = result.first;
      final columnMap = row.toColumnMap();

      return User(
          id: columnMap['id'] as String,
          name: name,
          email: email,
          createdAt: columnMap['created_at'] as DateTime? ?? DateTime.now(),
          updatedAt: columnMap['updated_at'] as DateTime);
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
       u.id as author_id, u.name as author_name, u.email as author_email, u.created_at as author_created_at, u.updated_at as author_updated_at
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
       u.id as author_id, u.name as author_name, u.email as author_email, u.created_at as author_created_at, u.updated_at as author_updated_at
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
SELECT id, name, email, created_at, updated_at
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
       u.id as author_id, u.name as author_name, u.email as author_email,
       u.created_at as author_created_at, 
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
SELECT u.id, u.name, u.email, u.created_at, u.updated_at,
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
       u.id as author_id, u.name as author_name, u.email as author_email, u.created_at as author_created_at, u.updated_at as author_updated_at
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
SELECT id, name, email, created_at, updated_at
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
SELECT p.id, p.name, p.language, p.description, p.archive, p.archive_type, p.source_type, p.url, p.vcs
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
          archiveType: PluginArchiveType.fromString(columnMap['archive_type'] as String),
          sourceType: PluginSourceType.fromString(columnMap['source_type'] as String),
          url: (columnMap['url'] as String?) == null ? null : Uri.parse(columnMap['url']),
          vcs: (columnMap['vcs'] as String?) == null ? null : VCS.fromString(columnMap['vcs'])
      );
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
  Future<AuthorizationSession> completeAuthSession(
      {required String sessionId,
      required String userId,
      String? accessToken,
      TaskStatus? newStatus}) async {

    // run transaction
    final result = await _pool.runTx((session) async {
      final hash;
      // get current status of session
      final rs = await session.execute(
          r'''SELECT expires_at, status, device_id FROM authorization_sessions WHERE session_id = $1''',
          parameters: [sessionId]);

      final row = rs.first.toColumnMap();

      // validate if expired or not
      final expiresAt = row['expires_at'] as DateTime;
      var status = TaskStatus.fromString(row['status'] as String);
      if (expiresAt.isBefore(DateTime.now()) && status == TaskStatus.pending)
        status = TaskStatus.expired;
      else if (newStatus != null) status = newStatus;

      // set access token if null
      // for the most part, logging in would require making a new access token, but what would happen to other devices?
      if (accessToken == null) {
        final updatedAt = DateTime.now();
        final accessTokenExpiresAt = updatedAt.add(Duration(days: 10));

        final userInfoQuery = await session.execute(
            r'''SELECT name, email FROM users WHERE id = $1''',
            parameters: [userId]);
        final userInfo = userInfoQuery.first.toColumnMap();

        // generate new token
        final (key: key, hash: accessTokenHash) = auth.createAccessTokenForUser(
          name: userInfo['name'],
          email: userInfo['email'],
          expiresAt: accessTokenExpiresAt,
        );
        accessToken ??= key;
        hash = accessTokenHash;
        final _ = await _pool.execute(r'''
INSERT INTO access_tokens (user_id, hash, token_type, device_id, expires_at)
VALUES ($1, $2, $3, $4, $5)
RETURNING *''', parameters: [
          userId,
          accessTokenHash,
          AccessTokenType.device,
          row['device_id'] as String,
          expiresAt
        ]);
      } else hash = auth.hashToken(accessToken!);

      return await session.execute(r'''
        UPDATE authorization_sessions
        SET user_id = $1, status = $2, access_token = $3, authorized_at = now()
        WHERE session_id = $4
        RETURNING *
      ''', parameters: [userId, status.name, hash, sessionId]);
    });

    final columnMap = result.first.toColumnMap();

    return AuthorizationSession(
      id: columnMap['id'] as String,
      sessionId: sessionId,
      deviceId: columnMap['device_id'] as String,
      status: TaskStatus.fromString(columnMap['status'] as String),
      authorizedAt: columnMap['authorized_at'] as DateTime,
      startedAt: columnMap['started_at'] as DateTime,
      expiresAt: columnMap['expires_at'] as DateTime,
      accessToken: accessToken,
      userId: userId,
      code: columnMap['code'] as String
    );
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> createNewAuthSession(
      {required String deviceId}) async {
    final enc = sha256.convert(utf8.encode(deviceId)).toString();
    final expiresAt = DateTime.now().add(Duration(hours: 1));

    final sessionId = Slugid(enc);

    final code = generateRandomCode();

    final result = await _pool.execute(r'''
    INSERT INTO authorization_sessions (session_id, expires_at, device_id, code)
    VALUES ($1, $2, $3, $4)
    RETURNING *
    ''', parameters: [sessionId.toString(), expiresAt, deviceId, code]);

    final row = result.first;
    final columnMap = row.toColumnMap();

    return AuthorizationSession(
      sessionId: sessionId.toString(),
      deviceId: deviceId,
      expiresAt: expiresAt,
      code: code,
      id: columnMap['id'] as String,
      startedAt: columnMap['started_at'] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  @Cacheable()
  Future<({TaskStatus status, String? id})> getAuthSessionStatus(
      {required String sessionId}) async {
    final result = await _pool.execute(
        r'''SELECT status, user_id FROM authorization_sessions WHERE session_id = $1''',
        parameters: [sessionId]);

    final row = result.first.toColumnMap();
    return (
      status: TaskStatus.fromString(row['status'] as String),
      id: row['user_id'] as String?
    );
  }

  @override
  FutureOr<(AccessToken, {String token})> createAccessTokenForUser(
      {required String id,
      AccessTokenType tokenType = AccessTokenType.device,
      String? description,
      String? deviceId,
      Map<String, dynamic>? deviceInfo}) async {
    late String token;
    DateTime createdAt = DateTime.now();
    DateTime expiresAt = createdAt.add(Duration(days: 10));

    /// Create an access token
    final result = await _pool.runTx((session) async {
      final userQuery =
          await session.execute(r'''SELECT name, email''', parameters: []);
      final userColumnMap = userQuery.first.toColumnMap();

      // generate the token
      final (key: accessToken, hash: accessTokenHash) =
          auth.createAccessTokenForUser(
        name: userColumnMap['name'],
        email: userColumnMap['email'],
        expiresAt: expiresAt,
      );

      /// set token
      token = accessToken;

      // add a new access token table
      return await session.execute(r'''
INSERT INTO access_tokens (user_id, hash, token_type, description, device_id, expires_at, device_info)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *''', parameters: [
        id,
        accessTokenHash,
        tokenType.name,
        description,
        deviceId,
        expiresAt,
        /* FIXME: This should be fixed */ deviceInfo
      ]);
    });

    final columnMap = result.first.toColumnMap();

    return (
      AccessToken(
          id: columnMap['id'] as String,
          userId: id,
          hash: columnMap['hash'] as String,
          tokenType: tokenType,
          description: columnMap['description'] as String?,
          deviceId: columnMap['device_id'] as String?,
          expiresAt: expiresAt,
          lastUsedAt: columnMap['last_used_at'] as DateTime,
          createdAt: createdAt,
          deviceInfo: columnMap['device_info'] as Map<String, dynamic>),
      token: token
    );
  }

  @override
  FutureOr<(AccessToken, {String token})> setAccessTokenForUser(
      {required String id,
      required String accessToken,
      required DateTime expiresAt,
      AccessTokenType tokenType = AccessTokenType.device,
      String? description,
      String? deviceId,
      Map<String, dynamic>? deviceInfo}) async {
    // hash token
    final hash = auth.hashToken(accessToken);

    final result = await _pool.execute(r'''
INSERT INTO access_tokens (user_id, hash, token_type, description, device_id, expires_at, device_info)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *''', parameters: [
      id,
      hash,
      tokenType.name,
      description,
      deviceId,
      expiresAt,
      /* FIXME: This should be fixed */ deviceInfo
    ]);

    final columnMap = result.first.toColumnMap();

    return (
      AccessToken(
          id: columnMap['id'] as String,
          userId: id,
          hash: columnMap['hash'] as String,
          tokenType: tokenType,
          description: columnMap['description'] as String?,
          deviceId: columnMap['device_id'] as String?,
          expiresAt: expiresAt,
          lastUsedAt: columnMap['last_used_at'] as DateTime,
          createdAt: columnMap['created_at'] as DateTime,
          deviceInfo: columnMap['device_info'] as Map<String, dynamic>),
      token: accessToken
    );
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> getAuthSessionDetails({required String sessionId}) async {
    if (_statements['getAuthSessionDetails'] == null) {
      _statements['getAuthSessionDetails'] = await _pool.prepare('''
SELECT id, session_id, user_id, status, authorized_at, started_at, expires_at, device_id, code, access_token
FROM authorization_sessions
WHERE session_id = @sessionId
''');
    }

    final result = await _statements['getAllVersionsOfPackage']!.run({
      'sessionId': sessionId
    });

    final columnMap = result.first.toColumnMap();

    return AuthorizationSession(
      id: columnMap['id'] as String,
      sessionId: sessionId,
      userId: columnMap['user_id'] as String?,
      authorizedAt: columnMap['authorized_at'] as DateTime,
      startedAt: columnMap['started_at'] as DateTime,
      expiresAt: columnMap['expires_at'] as DateTime,
      deviceId: columnMap['device_id'] as String,
      code: columnMap['code'] as String,
      accessToken: columnMap['access_token'] as String
    );
  }
}

extension Authorization on PrittDatabase {
  /// Check for the authorization of a user
  /// TODO: Implement a better way to check for authorization, maybe put this behind a cache
  @Cacheable()
  Future<User?> checkAuthorization(String accessToken, {AccessTokenType? tokenType}) async {
    bool noToken;

    // validate access token expiration
    if (accessToken.isEmpty) {
      throw UnauthorizedException('Access token is empty');
    }

    final result = await _pool.runTx((session) async {
      final rs = await session.execute(r'''SELECT hash FROM access_tokens''');
      final accessTokenHashes = rs.map((row) => row[0] as String);
      final successFullToken = accessTokenHashes.where((hash) => auth.validateAccessToken(accessToken, hash));
      if (successFullToken.isEmpty) {
        noToken = true;
      } else if (successFullToken.singleOrNull == null) {
        noToken = false;
      } else {
        return await session.execute(Sql.named('''
SELECT u.id, u.name, u.email, u.created_at, u.updated_at, a.token_type, a.expires_at as access_token_expires_at
FROM users u
INNER JOIN access_tokens a ON a.user_id = u.id
WHERE a.hash = @accessToken'''), parameters: {
          'accessToken': successFullToken.first
        });
      }
    });

    if (result == null)
      throw UnauthorizedException('Invalid access token', type: UnauthorizedExceptionType.INVALID_TOKEN, token: accessToken);
    if (result.isEmpty) {
      throw UnauthorizedException('Invalid access token', type: UnauthorizedExceptionType.INVALID_TOKEN, token: accessToken);
    }

    final row = result.first;
    final columnMap = row.toColumnMap();

    // if a token type is presented, validate the token type
    if (tokenType != null) {
      final targetTokenType = AccessTokenType.fromString(
          columnMap['token_type'] as String);
      if (targetTokenType != tokenType) {
        throw UnauthorizedException(
            'The device wanting to access with this access code is not authorized',
            type: UnauthorizedExceptionType.UNAUTHORIZED_DEVICE);
      }
    }

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
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
    );

    return user;
  }
}

String generateRandomCode({int length = 8, String? seed}) {
  final random = Random.secure();
  
  final characters = 'ABCDEFGHJKLMNOPQRSTUVWXYZ234567890';
  
  final input;
  if (seed == null) {
    input = characters;
  } else {
    var encodedSeed = base64Encode(utf8.encode(seed));
    input = encodedSeed.split('').where((c) => characters.contains(c)).join('');
  }

  String output = '';
  for (int i = 0; i < length; ++i) {
    output += characters[random.nextInt(characters.length - 1)];
  }

  return output;
}