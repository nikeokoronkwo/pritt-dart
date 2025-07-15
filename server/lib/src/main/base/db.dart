// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:pritt_common/version.dart';
import 'package:slugid/slugid.dart';

import '../crs/exceptions.dart';
import 'auth.dart';
import 'db/annotations/cache.dart';
import 'db/interface.dart';
import 'db/schema.dart';

/// The current implementation of the CRS Database makes use of [postgresql](https://www.postgresql.org/)
/// via the [postgres](https://pub.dev/packages/postgres) package.
///
/// It uses a connection Pool to handle multiple requests.
/// Certain requests are prepared for reuse throughout the API lifecycle to improve performance.
///
/// For more information on the APIs used in this class, see [PrittDatabaseInterface]
class PrittDatabase with SQLDatabase implements PrittDatabaseInterface {
  final Pool _pool;
  final PrittAuth auth;

  /// prepared statements
  final Map<String, Statement> _statements = {};

  PrittDatabase._({required Pool pool}) : _pool = pool, auth = PrittAuth();

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

  static void _preparePool(Pool pool) {
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
      final pool = Pool.withEndpoints(
        [
          Endpoint(
            host: host,
            database: database,
            username: username,
            password: password,
            port: port,
          ),
        ],
        settings: devMode
            ? PoolSettings(maxConnectionCount: 20, sslMode: SslMode.disable)
            : PoolSettings(
                maxConnectionCount: 20,
                sslMode: Platform.environment.containsKey('DATABASE_SSL')
                    ? SslMode.verifyFull
                    : SslMode.disable,
              ),
      );

      _preparePool(pool);

      db = PrittDatabase._(pool: pool);
    }
    dbConnections++;

    return db!;
  }

  /// Update the authentication credentials for a user
  Future updateUserCredentials(
    String id,
    String name,
    String email,
    String accessToken,
  ) async {}

  /// Execute basic SQL statements
  @override
  Future<Iterable<Map<String, dynamic>>> sql(String sql) async {
    return (await _pool.execute(sql)).map((future) => future.toColumnMap());
  }

  @override
  FutureOr<User> createUser({
    required String name,
    required String email,
  }) async {
    final id = Slugid.nice();

    // TODO: Access Token Generation
    try {
      final result = await _pool.execute(
        r'''
INSERT INTO users (id, name, email) 
VALUES ($1, $2, $3) 
RETURNING *''',
        parameters: [id, name, email],
      );

      final row = result.first;
      final columnMap = row.toColumnMap();

      return User(
        id: columnMap['id'] as String,
        name: name,
        email: email,
        createdAt: columnMap['created_at'] as DateTime? ?? DateTime.now(),
        updatedAt: columnMap['updated_at'] as DateTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Iterable<PackageVersions>> getAllVersionsOfPackage(
    String name, {
    Package? package,
    String? scope,
  }) async {
    // less cacheable
    if (_statements['getAllVersionsOfPackage'] == null) {
      _statements['getAllVersionsOfPackage'] = await _pool.prepare(
        Sql.named('''
SELECT version, version_type, created_at, info, env, metadata, archive, hash, signatures, integrity, readme, config, config_name,
       deprecated, deprecated_message, yanked
FROM package_versions
WHERE package_id = (SELECT id FROM packages WHERE name = @name AND scope IS NOT DISTINCT FROM @scope LIMIT 1)
'''),
      );
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
        versionType: VersionType.fromString(
          (columnMap['version_type'] as UndecodedBytes).asString,
        ),
        created: columnMap['created_at'] as DateTime,
        info: columnMap['info'] as Map<String, dynamic>,
        env: columnMap['env'] as Map<String, dynamic>,
        metadata: columnMap['metadata'] as Map<String, dynamic>,
        archive: Uri.file(columnMap['archive'] as String),
        hash: columnMap['hash'] as String,
        signatures: (columnMap['signatures'] as List<dynamic>)
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
    });
  }

  @override
  Future<Package> getPackage(
    String name, {
    String? language,
    String? scope,
  }) async {
    // cacheable
    if (_statements['getPackage'] == null) {
      _statements['getPackage'] = await _pool.prepare(
        Sql.named('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.vcs_url, p.archive, p.description, p.license, p.public,
       u.id as author_id, u.name as author_name, u.email as author_email, u.avatar_url as author_avatar_url, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name AND p.scope IS NOT DISTINCT FROM @scope
'''),
      );
    }
    final result = await _statements['getPackage']!.run({
      'name': name,
      'scope': scope,
    });

    if (result.isEmpty) {
      throw CRSException(
        CRSExceptionType.PACKAGE_NOT_FOUND,
        'Could not find package $name',
      );
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
        avatarUrl: columnMap['author_avatar_url'] as String?,
        createdAt: columnMap['author_created_at'] as DateTime,
        updatedAt: columnMap['author_updated_at'] as DateTime,
      ),
      language: columnMap['language'] as String,
      updated: columnMap['updated_at'] as DateTime,
      created: columnMap['created_at'] as DateTime,
      vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
      vcsUrl: columnMap['vcs_url'] != null
          ? Uri.parse(columnMap['vcs_url'] as String)
          : null,
      archive: Uri.directory(columnMap['archive'] as String),
      description: columnMap['description'] as String?,
      license: columnMap['license'] as String?,
      public: columnMap['public'] as bool?,
    );
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
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.vcs_url, p.archive, p.description, p.license, p.public,
       u.id as author_id, u.name as author_name, u.email as author_email, u.avatar_url as author_avatar_url, u.created_at as author_created_at, u.updated_at as author_updated_at
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
          avatarUrl: columnMap['author_avatar_url'] as String?,
          createdAt: columnMap['author_created_at'] as DateTime,
          updatedAt: columnMap['author_updated_at'] as DateTime,
        ),
        language: columnMap['language'] as String,
        updated: columnMap['updated_at'] as DateTime,
        created: columnMap['created_at'] as DateTime,
        vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
        vcsUrl: columnMap['vcs_url'] != null
            ? Uri.parse(columnMap['vcs_url'] as String)
            : null,
        archive: Uri.directory(columnMap['archive'] as String),
        description: columnMap['description'] as String?,
        license: columnMap['license'] as String?,
        public: columnMap['public'] as bool?,
      );
    });
  }

  @override
  FutureOr<Iterable<Package>> getPackagesForUser(String id) async {
    // cacheable
    if (_statements['getPackagesForUser'] == null) {
      _statements['getPackagesForUser'] = await _pool.prepare('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.vcs_url, p.archive, p.description, p.license, p.public,
       u.id as author_id, u.name as author_name, u.email as author_email, u.avatar_url as author_avatar_url, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE u.id = @userId
''');
    }

    final result = await _statements['getPackagesForUser']!.run({'userId': id});

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
          avatarUrl: columnMap['author_avatar_url'] as String?,
          createdAt: columnMap['author_created_at'] as DateTime,
          updatedAt: columnMap['author_updated_at'] as DateTime,
        ),
        language: columnMap['language'] as String,
        updated: columnMap['updated_at'] as DateTime,
        created: columnMap['created_at'] as DateTime,
        vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
        vcsUrl: columnMap['vcs_url'] != null
            ? Uri.parse(columnMap['vcs_url'] as String)
            : null,
        archive: Uri.directory(columnMap['archive'] as String),
        description: columnMap['description'] as String?,
        license: columnMap['license'] as String?,
        public: columnMap['public'] as bool?,
      );
    });
  }

  @override
  FutureOr<User> getUser(String id) async {
    // cacheable
    if (_statements['getUser'] == null) {
      _statements['getUser'] = await _pool.prepare(
        Sql.named('''
SELECT id, name, email, avatar_url, created_at, updated_at
FROM users
WHERE id = @userId
'''),
      );
    }

    final result = await _statements['getUser']!.run({'userId': id});

    try {
      final columnMap = result.first.toColumnMap();

      return User(
        id: id,
        name: columnMap['name'] as String,
        email: columnMap['email'] as String,
        createdAt: columnMap['created_at'] as DateTime,
        updatedAt: columnMap['updated_at'] as DateTime,
        avatarUrl: columnMap['avatar_url'] as String?,
      );
    } on StateError catch (e, st) {
      throw CRSException(
        CRSExceptionType.USER_NOT_FOUND,
        'Could not find user with id $id',
        e,
        st,
      );
    }
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
SELECT id, name, email, avatar_url, created_at, updated_at
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
        avatarUrl: columnMap['avatar_url'] as String?,
        createdAt: columnMap['created_at'] as DateTime,
        updatedAt: columnMap['updated_at'] as DateTime,
      );
    });
  }

  @override
  FutureOr<PackageVersions> getPackageWithVersion(
    String name,
    Version version, {
    String? scope,
  }) async {
    // cacheable
    if (_statements['getPackageWithVersion'] == null) {
      _statements['getPackageWithVersion'] = await _pool.prepare(
        Sql.named('''
SELECT pv.version, pv.version_type, pv.created_at, pv.info, pv.env, pv.metadata, pv.archive, 
       pv.hash, pv.signatures, pv.integrity, pv.readme, pv.config, pv.config_name, 
       pv.deprecated, pv.deprecated_message, pv.yanked, 
       p.id as package_id, p.name as package_name, p.scope as package_scope, p.language as package_language, p.created_at as package_created_at, 
       p.updated_at as package_updated_at, p.version as package_latest_version, p.vcs as package_vcs, p.vcs_url as package_vcs_url, 
       p.archive as package_archive, p.description as package_description, p.license as package_license, p.public as package_public,
       u.id as author_id, u.name as author_name, u.email as author_email, u.avatar_url as author_avatar_url,
       u.created_at as author_created_at, 
       u.updated_at as author_updated_at
FROM package_versions pv
INNER JOIN packages p ON pv.package_id = p.id
LEFT JOIN users u ON p.author_id = u.id
WHERE p.name = @name AND pv.version = @version AND p.scope IS NOT DISTINCT FROM @scope
LIMIT 1
'''),
      );
    }
    final result = await _statements['getPackageWithVersion']!.run({
      'name': name,
      'version': version.toString(),
      'scope': scope,
    });

    if (result.isEmpty) {
      throw CRSException(
        CRSExceptionType.VERSION_NOT_FOUND,
        'Could not find package $name with version $version',
      );
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
          avatarUrl: columnMap['author_avatar_url'] as String?,
          createdAt: columnMap['author_created_at'] as DateTime,
          updatedAt: columnMap['author_updated_at'] as DateTime,
        ),
        language: columnMap['package_language'] as String,
        created: columnMap['package_created_at'] as DateTime,
        updated: columnMap['package_updated_at'] as DateTime,
        vcs: VCS.fromString(
          (columnMap['package_vcs'] as UndecodedBytes).asString,
        ),
        vcsUrl: columnMap['package_vcs_url'] != null
            ? Uri.parse(columnMap['package_vcs_url'] as String)
            : null,
        archive: Uri.directory(columnMap['package_archive'] as String),
        description: columnMap['package_description'] as String?,
        license: columnMap['package_license'] as String?,
        public: columnMap['package_public'] as bool?,
      ),
      version: version.toString(),
      versionType: VersionType.fromString(
        (columnMap['version_type'] as UndecodedBytes).asString,
      ),
      created: columnMap['created_at'] as DateTime,
      info: columnMap['info'] as Map<String, dynamic>,
      env: columnMap['env'] as Map<String, dynamic>,
      metadata: columnMap['metadata'] as Map<String, dynamic>,
      archive: Uri.file(columnMap['archive'] as String),
      hash: columnMap['hash'] as String,
      signatures: (columnMap['signatures'] as List<dynamic>)
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
  FutureOr<PackageVersions> updateNewPackageWithArchiveDetails({
    required String name,
    required String version,
    required String hash,
    required String signature,
    required String integrity,
  }) {
    // TODO: implement updateNewPackageWithArchiveDetails
    throw UnimplementedError();
  }

  @override
  FutureOr<User> updateUser({
    required String name,
    required String email,
    User Function(User p1)? updates,
  }) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<User, Iterable<Privileges>>> getContributorsForPackage(
    String name, {
    String? scope,
  }) async {
    // not cacheable

    final result = await _pool.execute(
      Sql.named('''
SELECT u.id, u.name, u.email, u.created_at, u.updated_at, u.avatar_url,
       pc.package_id as package_id, pc.privileges as privileges
FROM package_contributors pc
LEFT JOIN users u ON pc.contributor_id = u.id
WHERE pc.package_id = (SELECT id FROM packages WHERE name = @name AND scope IS NOT DISTINCT FROM @scope LIMIT 1)
'''),
      parameters: {'name': name, 'scope': scope},
    );

    return result.asMap().map((k, row) {
      final columnMap = row.toColumnMap();
      return MapEntry(
        User(
          id: columnMap['id'] as String,
          name: columnMap['name'] as String,
          email: columnMap['email'] as String,
          avatarUrl: columnMap['avatar_url'] as String?,
          createdAt: columnMap['created_at'] as DateTime,
          updatedAt: columnMap['updated_at'] as DateTime,
        ),
        (columnMap['privileges'] as Iterable<UndecodedBytes>).map(
          (p) => Privileges.fromString(p.asString),
        ),
      );
    });
  }

  // STREAMS

  @override
  Stream<Package> getPackagesForUserStream(String id) async* {
    // less cacheable
    if (_statements['getPackagesForUser'] == null) {
      _statements['getPackagesForUser'] = await _pool.prepare(
        Sql.named('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.license, p.description, p.public,
       u.id as author_id, u.name as author_name, u.avatar_url as author_avatar_url, u.email as author_email, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
WHERE u.id = @userId
'''),
      );
    }
    final result = _statements['getPackagesForUser']!.run({'userId': id});

    yield* Stream.fromFuture(result).asyncExpand(
      (e) => Stream.fromIterable(
        e.map((row) {
          final columnMap = row.toColumnMap();
          return Package(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            version: columnMap['version'] as String,
            author: User(
              id: columnMap['author_id'] as String,
              name: columnMap['author_name'] as String,
              email: columnMap['author_email'] as String,
              avatarUrl: columnMap['author_avatar_url'] as String?,
              createdAt: columnMap['author_created_at'] as DateTime,
              updatedAt: columnMap['author_updated_at'] as DateTime,
            ),
            language: columnMap['language'] as String,
            updated: columnMap['updated_at'] as DateTime,
            created: columnMap['created_at'] as DateTime,
            vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
            archive: Uri.directory(columnMap['archive'] as String),
            description: columnMap['description'] as String?,
            license: columnMap['license'] as String?,
            public: columnMap['public'] as bool?,
          );
        }),
      ),
    );
  }

  @override
  Stream<Package> getPackagesStream() async* {
    // less cacheable
    if (_statements['getPackages'] == null) {
      _statements['getPackages'] = await _pool.prepare('''
SELECT p.id, p.name, p.scope, p.version, p.language, p.created_at, p.updated_at, p.vcs, p.archive, p.license, p.description, p.public,
       u.id as author_id, u.name as author_name, u.avatar_url as author_avatar_url, u.email as author_email, u.created_at as author_created_at, u.updated_at as author_updated_at
FROM packages p
LEFT JOIN users u ON p.author_id = u.id
''');
    }
    final result = _statements['getPackages']!.run([]);

    yield* Stream.fromFuture(result).asyncExpand(
      (e) => Stream.fromIterable(
        e.map((row) {
          final columnMap = row.toColumnMap();
          return Package(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            version: columnMap['version'] as String,
            author: User(
              id: columnMap['author_id'] as String,
              name: columnMap['author_name'] as String,
              email: columnMap['author_email'] as String,
              avatarUrl: columnMap['author_avatar_url'] as String?,
              createdAt: columnMap['author_created_at'] as DateTime,
              updatedAt: columnMap['author_updated_at'] as DateTime,
            ),
            language: columnMap['language'] as String,
            updated: columnMap['updated_at'] as DateTime,
            created: columnMap['created_at'] as DateTime,
            vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
            archive: Uri.directory(columnMap['archive'] as String),
            description: columnMap['description'] as String?,
            license: columnMap['license'] as String?,
            public: columnMap['public'] as bool?,
          );
        }),
      ),
    );
  }

  @override
  Stream<User> getUsersStream() async* {
    // less cacheable
    if (_statements['getUsers'] == null) {
      _statements['getUsers'] = await _pool.prepare('''
SELECT id, name, email, avatar_url, created_at, updated_at
FROM users
''');
    }
    final result = _statements['getUsers']!.run([]);

    yield* Stream.fromFuture(result).asyncExpand(
      (e) => Stream.fromIterable(
        e.map((row) {
          final columnMap = row.toColumnMap();
          return User(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            email: columnMap['email'] as String,
            avatarUrl: columnMap['avatar_url'] as String?,
            createdAt: columnMap['created_at'] as DateTime,
            updatedAt: columnMap['updated_at'] as DateTime,
          );
        }),
      ),
    );
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
        archiveType: PluginArchiveType.fromString(
          (columnMap['archive_type'] as UndecodedBytes).asString,
        ),
        sourceType: PluginSourceType.fromString(
          (columnMap['source_type'] as UndecodedBytes).asString,
        ),
        url: (columnMap['url'] as String?) == null
            ? null
            : Uri.parse(columnMap['url']),
        vcs: (columnMap['vcs'] as String?) == null
            ? null
            : VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
      );
    });
  }

  @override
  FutureOr<Package> addContributorToPackage(
    String name,
    User user,
    List<Privileges> privileges, {
    String? scope,
  }) {
    // TODO: implement addContributorToPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopeUsers> addUserToOrganization({
    required String organizationName,
    required User user,
    Iterable<Privileges> privileges = const [],
  }) {
    // TODO: implement addUserToOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Scope> createOrganization({
    required String name,
    String? description,
    required User owner,
    bool private = false,
  }) {
    // TODO: implement createOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<User, Iterable<Privileges>>> getMembersForOrganization(
    String name,
  ) async {
    final result = await _pool.execute(
      Sql.named('''
SELECT u.id, u.name, u.email, u.avatar_url, u.created_at, u.updated_at,
       o.name as organization_name, o.description as organization_description, o.public as organization_public,
       om.privileges as privileges
FROM organization_members om
LEFT JOIN users u ON om.user_id = u.id
LEFT JOIN organizations o ON om.organization_id = o.id
WHERE o.name = @name
'''),
      parameters: {'name': name},
    );

    return result.asMap().map((k, row) {
      final columnMap = row.toColumnMap();
      return MapEntry(
        User(
          id: columnMap['id'] as String,
          name: columnMap['name'] as String,
          email: columnMap['email'] as String,
          avatarUrl: columnMap['avatar_url'] as String?,
          createdAt: columnMap['created_at'] as DateTime,
          updatedAt: columnMap['updated_at'] as DateTime,
        ),
        (columnMap['privileges'] as Iterable<UndecodedBytes>).map(
          (p) => Privileges.fromString(p.asString),
        ),
      );
    });
  }

  @override
  Stream<User> getMembersForOrganizationStream(String name) async* {
    final result = _pool.execute(
      Sql.named('''
SELECT u.id, u.name, u.email, u.avatar_url, u.created_at, u.updated_at,
       o.name as organization_name, o.description as organization_description, o.public as organization_public,
       om.privileges as privileges
FROM organization_members om
LEFT JOIN users u ON om.user_id = u.id
LEFT JOIN organizations o ON om.organization_id = o.id
WHERE o.name = @name
'''),
      parameters: {'name': name},
    );

    yield* Stream.fromFuture(result).asyncExpand(
      (e) => Stream.fromIterable(
        e.map((row) {
          final columnMap = row.toColumnMap();
          return User(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            email: columnMap['email'] as String,
            avatarUrl: columnMap['avatar_url'] as String?,
            createdAt: columnMap['created_at'] as DateTime,
            updatedAt: columnMap['updated_at'] as DateTime,
          );
        }),
      ),
    );
  }

  @override
  FutureOr<Scope> getOrganizationByName(String name) async {
    final result = await _pool.execute(
      Sql.named('''
SELECT id, name, description, created_at, updated_at, public
FROM organizations
WHERE name = @name
'''),
      parameters: {'name': name},
    );

    if (result.isEmpty) {
      throw CRSException(
        CRSExceptionType.SCOPE_NOT_FOUND,
        'Could not find organization with name $name',
      );
    }

    final columnMap = result.first.toColumnMap();
    return Scope(
      id: columnMap['id'] as String,
      name: columnMap['name'] as String,
      description: columnMap['description'] as String?,
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
      public: columnMap['public'] as bool,
    );
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
  FutureOr<ScopeUsers> removeUserFromOrganization({
    required String organizationName,
    required User user,
  }) {
    // TODO: implement removeUserFromOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<Scope> updateOrganization({
    required String name,
    Scope Function(Scope p1)? updates,
  }) {
    // TODO: implement updateOrganization
    throw UnimplementedError();
  }

  @override
  FutureOr<ScopeUsers> updateUserPrivilegesInOrganization({
    required String organizationName,
    required User user,
    Iterable<Privileges> privileges = const [],
  }) {
    // TODO: implement updateUserPrivilegesInOrganization
    throw UnimplementedError();
  }

  // TODO: VCS Url
  @override
  FutureOr<Package> addNewPackage({
    required String name,
    String? scope,
    String? description,
    required String version,
    required User author,
    required String language,
    required VCS vcs,
    String? vcsUrl,
    String? license,
    required Uri archive,
    Iterable<User>? contributors,
    bool private = false,
  }) async {
    final id = Slugid.nice().toString();
    try {
      final result = await _pool.execute(
        r'''
INSERT INTO packages (id, name, scope, version, description, author_id, language, vcs, vcs_url, archive, license, public)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
RETURNING *''',
        parameters: [
          id,
          name,
          scope,
          version,
          description,
          author.id,
          language,
          vcs.name,
          vcsUrl,
          archive.toFilePath(windows: false),
          license,
          !private,
        ],
      );

      if ((contributors ?? []).isNotEmpty) {
        await contributors
            ?.map(
              (c) async => await addContributorToPackage(name, c, [
                Privileges.write,
                Privileges.read,
              ], scope: scope),
            )
            .wait;
      }

      final columnMap = result.first.toColumnMap();

      return Package(
        id: id,
        name: name,
        scope: scope,
        version: version,
        description: description,
        author: author,
        language: language,
        created: columnMap['created_at'] as DateTime,
        updated: columnMap['updated_at'] as DateTime,
        vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
        vcsUrl: vcsUrl == null ? null : Uri.parse(vcsUrl),
        archive: archive,
        license: license,
      );
    } catch (e, stack) {
      throw CRSException(
        CRSExceptionType.INCOMPATIBLE_PACKAGE,
        e.toString(),
        e,
        stack,
      );
    }
  }

  // Brief workaround
  FutureOr<PackageVersions> addNewVersionOfPackageGivenPkg({
    required Package pkg,
    required String version,
    VersionType? versionType,
    required String hash,
    required String signature,
    required String integrity,
    String? readme,
    String? config,
    String? configName,
    Map<String, dynamic> info = const {},
    Map<String, String> env = const {},
    Map<String, dynamic> metadata = const {},
    required Uri archive,
    Iterable<String>? contributors,
  }) async {
    final sig = Signature(
      publicKeyId: '',
      signature: signature,
      created: DateTime.now(),
    );
    final result = await _pool.runTx((session) async {
      // TODO: Get version type
      final v = Version.parse(version);
      final oldV = Version.parse(pkg.version);
      final versionType = v.versionType;

      if (v > oldV)
        await session.execute(
          Sql.named(
            r'''UPDATE packages SET version = @version WHERE name = @name AND scope IS NOT DISTINCT FROM @scope''',
          ),
          parameters: {
            'name': pkg.name,
            'scope': pkg.scope,
            'version': version,
          },
        );

      return await session.execute(
        r'''
INSERT INTO package_versions (package_id, version, version_type, readme, config, config_name, info, env, metadata, archive, hash, signatures, integrity)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
RETURNING *''',
        parameters: [
          pkg.id,
          version,
          versionType.name,
          readme,
          config,
          configName,
          info,
          env,
          metadata,
          archive.toFilePath(windows: false),
          hash,
          jsonEncode([sig.toJson()]),
          integrity,
        ],
      );
    });

    final columnMap = result.first.toColumnMap();

    return PackageVersions(
      package: pkg,
      version: version,
      versionType: VersionType.fromString(
        (columnMap['version_type'] as UndecodedBytes).asString,
      ),
      created: columnMap['created_at'] as DateTime,
      readme: readme,
      config: config,
      configName: configName,
      info: info,
      env: env,
      metadata: metadata,
      archive: archive,
      hash: hash,
      signatures: [sig],
      integrity: integrity,
    );
  }

  @override
  FutureOr<PackageVersions> addNewVersionOfPackage({
    required String name,
    String? scope,
    required String version,
    VersionType? versionType,
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
    required Uri archive,
    Iterable<String>? contributors,
  }) async {
    final sig = Signature(
      publicKeyId: '',
      signature: signature,
      created: DateTime.now(),
    );
    final p = await getPackage(name, language: language, scope: scope);
    final result = await _pool.runTx((session) async {
      // TODO: Get version type
      final v = Version.parse(version);
      final oldV = Version.parse(p.version);
      final versionType = v.versionType;

      if (v > oldV)
        await session.execute(
          Sql.named(
            r'''UPDATE packages SET version = @version WHERE name = @name AND scope IS NOT DISTINCT FROM @scope''',
          ),
          parameters: {'name': name, 'scope': scope, 'version': version},
        );

      return await session.execute(
        r'''
INSERT INTO package_versions (package_id, version, version_type, readme, config, config_name, info, env, metadata, archive, hash, signatures, integrity)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
RETURNING *''',
        parameters: [
          p.id,
          version,
          versionType.name,
          readme,
          config,
          configName,
          info,
          env,
          metadata,
          archive.toFilePath(windows: false),
          hash,
          jsonEncode([sig.toJson()]),
          integrity,
        ],
      );
    });

    final columnMap = result.first.toColumnMap();

    return PackageVersions(
      // TODO: Why should we have to make this call twice (three times in Postgres) when initing a package?
      package: p,
      version: version,
      versionType: VersionType.fromString(
        (columnMap['version_type'] as UndecodedBytes).asString,
      ),
      created: columnMap['created_at'] as DateTime,
      readme: readme,
      config: config,
      configName: configName,
      info: info,
      env: env,
      metadata: metadata,
      archive: archive,
      hash: hash,
      signatures: [sig],
      integrity: integrity,
    );
  }

  @override
  FutureOr<PackageVersions> deprecateVersionOfPackage(
    String name,
    Version version, {
    String? scope,
  }) {
    // TODO: implement deprecateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  Stream<PackageVersions> getAllVersionsOfPackageStream(
    String name, {
    String? scope,
  }) async* {
    if (_statements['getAllVersionsOfPackage'] == null) {
      _statements['getAllVersionsOfPackage'] = await _pool.prepare(
        Sql.named('''
SELECT version, version_type, created_at, info, env, metadata, archive, hash, signatures, integrity, readme, config, config_name,
       deprecated, deprecated_message, yanked
FROM package_versions
WHERE package_id = (SELECT id FROM packages WHERE name = @name AND scope IS NOT DISTINCT FROM @scope LIMIT 1)
'''),
      );
    }

    final result = _statements['getAllVersionsOfPackage']!.run({
      'name': name,
      'scope': scope,
    });

    final pkg = await getPackage(name);

    yield* Stream.fromFuture(result).asyncExpand((res) {
      return Stream.fromIterable(res).map((row) {
        final columnMap = row.toColumnMap();
        return PackageVersions(
          package: pkg,
          version: columnMap['version'] as String,
          versionType: VersionType.fromString(
            (columnMap['version_type'] as UndecodedBytes).asString,
          ),
          created: columnMap['created_at'] as DateTime,
          info: columnMap['info'] as Map<String, dynamic>,
          env: columnMap['env'] as Map<String, dynamic>,
          metadata: columnMap['metadata'] as Map<String, dynamic>,
          archive: Uri.file(columnMap['archive'] as String),
          hash: columnMap['hash'] as String,
          signatures: (columnMap['signatures'] as List<dynamic>)
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
      });
    });
  }

  @override
  FutureOr<Package> updatePackage(
    String name,
    Package Function(Package p1) updates, {
    String? scope,
  }) {
    // TODO: implement updatePackage
    throw UnimplementedError();
  }

  @override
  FutureOr<Package> updateVersionOfPackage(
    String name,
    Version version,
    PackageVersions Function(PackageVersions p1) updates, {
    String? scope,
  }) {
    // TODO: implement updateVersionOfPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<PackageVersions> yankVersionOfPackage(
    String name,
    Version version, {
    String? scope,
  }) {
    // TODO: implement yankVersionOfPackage
    throw UnimplementedError();
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> completeAuthSession({
    required String sessionId,
    required String userId,
    TaskStatus? newStatus,
  }) async {
    // run transaction
    final result = await _pool.runTx((session) async {
      // get current status of session
      final rs = await session.execute(
        r'''SELECT expires_at, status, device_id FROM authorization_sessions WHERE session_id = $1''',
        parameters: [sessionId],
      );

      final row = rs.first.toColumnMap();

      // validate if expired or not
      final expiresAt = row['expires_at'] as DateTime;
      var status = TaskStatus.fromString(
        (row['status'] as UndecodedBytes).asString,
      );
      if (expiresAt.isBefore(DateTime.now()) && status == TaskStatus.pending) {
        status = TaskStatus.expired;
      } else if (newStatus != null)
        status = newStatus;

      return await session.execute(
        r'''
        UPDATE authorization_sessions
        SET user_id = $1, status = $2, authorized_at = now()
        WHERE session_id = $3
        RETURNING *
      ''',
        parameters: [userId, status.name, sessionId],
      );
    });

    final columnMap = result.first.toColumnMap();

    return AuthorizationSession(
      id: columnMap['id'] as String,
      sessionId: sessionId,
      deviceId: columnMap['device_id'] as String,
      status: TaskStatus.fromString(
        (columnMap['status'] as UndecodedBytes).asString,
      ),
      authorizedAt: columnMap['authorized_at'] as DateTime,
      startedAt: columnMap['started_at'] as DateTime,
      expiresAt: columnMap['expires_at'] as DateTime,
      userId: userId,
      code: columnMap['code'] as String,
    );
  }

  @override
  Future<
    ({AuthorizationSession session, String token, DateTime tokenExpiration})
  >
  updateAuthSessionWithAccessToken({required String sessionId}) async {
    String? token;
    final updatedAt = DateTime.now();
    final accessTokenExpiresAt = updatedAt.add(Duration(days: 10));

    try {
      final result = await _pool.runTx((session) async {
        final String hash;
        // get current status of session
        final rs = await session.execute(
          r'''SELECT user_id, device_id FROM authorization_sessions WHERE session_id = $1''',
          parameters: [sessionId],
        );

        final row = rs.first.toColumnMap();

        // set access token
        // for the most part, logging in would require making a new access token, but what would happen to other devices?

        final userInfoQuery = await session.execute(
          r'''SELECT name, email FROM users WHERE id = $1''',
          parameters: [row['user_id'] as String],
        );
        final userInfo = userInfoQuery.first.toColumnMap();

        // generate new token
        final (key: key, hash: accessTokenHash) = auth.createAccessTokenForUser(
          name: userInfo['name'],
          email: userInfo['email'],
          expiresAt: accessTokenExpiresAt,
        );
        token = key;
        hash = accessTokenHash;

        final _ = await _pool.execute(
          r'''
INSERT INTO access_tokens (user_id, hash, token_type, device_id, expires_at)
VALUES ($1, $2, $3, $4, $5)
RETURNING *''',
          parameters: [
            row['user_id'] as String,
            accessTokenHash,
            AccessTokenType.device.name,
            row['device_id'] as String,
            accessTokenExpiresAt,
          ],
        );

        return await session.execute(
          r'''
        UPDATE authorization_sessions
        SET access_token = $1, authorized_at = now()
        WHERE session_id = $2
        RETURNING *
      ''',
          parameters: [hash, sessionId],
        );
      });

      final columnMap = result.first.toColumnMap();

      return (
        session: AuthorizationSession(
          id: columnMap['id'] as String,
          sessionId: sessionId,
          deviceId: columnMap['device_id'] as String,
          status: TaskStatus.fromString(
            (columnMap['status'] as UndecodedBytes).asString,
          ),
          authorizedAt: columnMap['authorized_at'] as DateTime,
          startedAt: columnMap['started_at'] as DateTime,
          expiresAt: columnMap['expires_at'] as DateTime,
          userId: columnMap['user_id'] as String,
          accessToken: (token ?? columnMap['access_token']) as String,
          code: columnMap['code'] as String,
        ),
        token: (token ?? columnMap['access_token']) as String,
        tokenExpiration: accessTokenExpiresAt,
      );
    } on StateError catch (e, st) {
      throw CRSException(
        CRSExceptionType.ITEM_NOT_FOUND,
        'The given item could not be found',
        e,
        st,
      );
    }
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> createNewAuthSession({
    required String deviceId,
  }) async {
    var dateTime = DateTime.now();
    final enc = sha256
        .convert(utf8.encode(deviceId + dateTime.toIso8601String()))
        .toString();

    final expiresAt = dateTime.add(Duration(hours: 1));

    final sessionId = enc.substring(0, 10);

    final code = generateRandomCode();

    final result = await _pool.execute(
      r'''
    INSERT INTO authorization_sessions (session_id, expires_at, device_id, code)
    VALUES ($1, $2, $3, $4)
    RETURNING *
    ''',
      parameters: [sessionId.toString(), expiresAt, deviceId, code],
    );

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
  Future<({TaskStatus status, String? id})> getAuthSessionStatus({
    required String sessionId,
  }) async {
    final result = await _pool.execute(
      r'''SELECT status, user_id FROM authorization_sessions WHERE session_id = $1''',
      parameters: [sessionId],
    );

    final row = result.first.toColumnMap();
    return (
      status: TaskStatus.fromString((row['status'] as UndecodedBytes).asString),
      id: row['user_id'] as String?,
    );
  }

  @override
  FutureOr<(AccessToken, {String token})> createAccessTokenForUser({
    required String id,
    AccessTokenType tokenType = AccessTokenType.device,
    String? description,
    String? deviceId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    late String token;
    DateTime createdAt = DateTime.now();
    DateTime expiresAt = createdAt.add(Duration(days: 10));

    /// Create an access token
    final result = await _pool.runTx((session) async {
      final userQuery = await session.execute(
        r'''SELECT name, email''',
        parameters: [],
      );
      final userColumnMap = userQuery.first.toColumnMap();

      // generate the token
      final (key: accessToken, hash: accessTokenHash) = auth
          .createAccessTokenForUser(
            name: userColumnMap['name'],
            email: userColumnMap['email'],
            expiresAt: expiresAt,
          );

      /// set token
      token = accessToken;

      // add a new access token table
      return await session.execute(
        r'''
INSERT INTO access_tokens (user_id, hash, token_type, description, device_id, expires_at, device_info)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *''',
        parameters: [
          id,
          accessTokenHash,
          tokenType.name,
          description,
          deviceId,
          expiresAt,
          /* FIXME: This should be fixed */ deviceInfo,
        ],
      );
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
        deviceInfo: columnMap['device_info'] as Map<String, dynamic>,
      ),
      token: token,
    );
  }

  @override
  FutureOr<(AccessToken, {String token})> setAccessTokenForUser({
    required String id,
    required String accessToken,
    required DateTime expiresAt,
    AccessTokenType tokenType = AccessTokenType.device,
    String? description,
    String? deviceId,
    Map<String, dynamic>? deviceInfo,
  }) async {
    // hash token
    final hash = auth.hashToken(accessToken);

    final result = await _pool.execute(
      r'''
INSERT INTO access_tokens (user_id, hash, token_type, description, device_id, expires_at, device_info)
VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *''',
      parameters: [
        id,
        hash,
        tokenType.name,
        description,
        deviceId,
        expiresAt,
        /* FIXME: This should be fixed */ deviceInfo,
      ],
    );

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
        deviceInfo: columnMap['device_info'] as Map<String, dynamic>,
      ),
      token: accessToken,
    );
  }

  @override
  @Cacheable()
  Future<AuthorizationSession> getAuthSessionDetails({
    required String sessionId,
  }) async {
    if (_statements['getAuthSessionDetails'] == null) {
      _statements['getAuthSessionDetails'] = await _pool.prepare(
        Sql.named('''
SELECT id, session_id, user_id, status, authorized_at, started_at, expires_at, device_id, code, access_token
FROM authorization_sessions
WHERE session_id = @sessionId
'''),
      );
    }

    final result = await _statements['getAuthSessionDetails']!.run({
      'sessionId': sessionId,
    });

    try {
      final columnMap = result.first.toColumnMap();

      return AuthorizationSession(
        id: columnMap['id'] as String,
        sessionId: sessionId,
        userId: columnMap['user_id'] as String?,
        authorizedAt: columnMap['authorized_at'] as DateTime?,
        startedAt: columnMap['started_at'] as DateTime,
        expiresAt: columnMap['expires_at'] as DateTime,
        deviceId: columnMap['device_id'] as String,
        code: columnMap['code'] as String,
        accessToken: columnMap['access_token'] as String?,
      );
    } on StateError catch (e, st) {
      throw CRSException(
        CRSExceptionType.ITEM_NOT_FOUND,
        'The auth session with id: $sessionId cannot be found',
        e,
        st,
      );
    }
  }

  @override
  FutureOr<PublishingTask> createNewPublishingTask({
    required String name,
    String? scope,
    required String version,
    required User user,
    required String language,
    bool newPkg = false,
    required String config,
    required Map<String, dynamic> configData,
    Map<String, dynamic>? metadata,
    Map<String, String>? env,
    VCS? vcs,
    String? vcsUrl,
  }) async {
    // create an expires-at time
    final currentDate = DateTime.now();
    final expiresAtDate = currentDate.add(Duration(days: 3));

    final result = await _pool.execute(
      r'''
INSERT INTO package_publishing_tasks (user_id, name, scope, version, new, language, config, config_map, metadata, env, vcs, vcs_url, expires_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
RETURNING *
''',
      parameters: [
        user.id,
        name,
        scope,
        version,
        newPkg,
        language,
        config,
        configData,
        metadata ?? {},
        env ?? {},
        vcs?.name,
        vcsUrl,
        expiresAtDate,
      ],
    );

    final columnMap = result.first.toColumnMap();

    return PublishingTask(
      id: columnMap['id'] as String,
      status: TaskStatus.fromString(
        (columnMap['status'] as UndecodedBytes).asString,
      ),
      message: columnMap['message'] as String?,
      name: name,
      scope: scope,
      user: user.id,
      version: version,
      $new: columnMap['new'] as bool,
      language: language,
      config: config,
      configMap: configData,
      metadata: metadata ?? {},
      env: env ?? {},
      vcs: vcs ?? VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
      vcsUrl: vcsUrl == null ? null : Uri.parse(vcsUrl),
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
      expiresAt: expiresAtDate,
    );
  }

  @override
  FutureOr<(Package, PackageVersions)> createPackageFromPublishingTask(
    String id, {
    String? description,
    String? license,
    VersionType? versionType,
    String? readme,
    required String rawConfig,
    Map<String, dynamic>? info,
    required Uri archive,
    required String hash,
    List<Signature> signatures = const [],
    required String integrity,
    PublishingTask? task,
    List<String> contributorIds = const [],
    bool private = false,
  }) async {
    // get publishing task from db
    task ??= await getPublishingTaskById(id);

    final author = await getUser(task.user);

    return await Future.sync(
      () => addNewPackage(
        name: task!.name,
        scope: task.scope,
        version: task.version,
        description: description,
        author: author,
        language: task.language,
        vcs: task.vcs,
        archive: archive,
        private: private,
      ),
    ).then((pkg) async {
      final pkgVer = await addNewVersionOfPackageGivenPkg(
        pkg: pkg,
        version: task!.version,
        hash: hash,
        signature: signatures.firstOrNull?.signature ?? '',
        integrity: integrity,
        readme: readme,
        config: rawConfig,
        configName: task.config,
        info: info ?? {},
        env: task.env,
        contributors: contributorIds,
        metadata: task.configMap,
        archive: archive,
      );

      return (pkg, pkgVer);
    });
  }

  @override
  FutureOr<PackageVersions> createPackageVersionFromPublishingTask(
    String id, {
    VersionType? versionType,
    String? readme,
    String? description,
    required String rawConfig,
    Map<String, dynamic>? info,
    required Uri archive,
    required String hash,
    List<Signature> signatures = const [],
    required String integrity,
    PublishingTask? task,
    List<String> contributorIds = const [],
    bool private = false,
  }) async {
    task ??= await getPublishingTaskById(id);

    final author = await getUser(task.user);

    final pkgVer = await addNewVersionOfPackage(
      name: task.name,
      scope: task.scope,
      version: task.version,
      description: description,
      hash: hash,
      signature: signatures.firstOrNull?.signature ?? '',
      integrity: integrity,
      readme: readme,
      config: rawConfig,
      configName: task.config,
      info: info ?? {},
      env: task.env,
      contributors: contributorIds,
      metadata: task.configMap,
      author: author,
      language: task.language,
      vcs: task.vcs,
      archive: archive,
    );

    return pkgVer;
  }

  @override
  FutureOr<PublishingTask> getPublishingTaskById(String id) async {
    if (_statements['getPublishingTaskById'] == null) {
      _statements['getPublishingTaskById'] = await _pool.prepare(
        Sql.named('''
SELECT id, status, user_id, name, scope, version, new, language, config, config_map, metadata, env, vcs, vcs_url, updated_at, created_at, expires_at, message
FROM package_publishing_tasks
WHERE id = @id
'''),
      );
    }

    final result = await _statements['getPublishingTaskById']!.run({'id': id});

    try {
      final columnMap = result.first.toColumnMap();
      final vcsUrl = columnMap['vcs_url'] as String?;

      return PublishingTask(
        id: columnMap['id'] as String,
        name: columnMap['name'] as String,
        scope: columnMap['scope'] as String?,
        status: TaskStatus.fromString(
          (columnMap['status'] as UndecodedBytes).asString,
        ),
        message: columnMap['message'] as String?,
        user: columnMap['user_id'] as String,
        version: columnMap['version'] as String,
        $new: columnMap['new'] as bool,
        language: columnMap['language'] as String,
        config: columnMap['config'] as String,
        configMap: columnMap['config_map'],
        metadata: columnMap['metadata'],
        env: (columnMap['env'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v is String ? v : v.toString()),
        ),
        vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
        vcsUrl: vcsUrl == null ? null : Uri.parse(vcsUrl),
        createdAt: columnMap['created_at'] as DateTime,
        updatedAt: columnMap['updated_at'] as DateTime,
        expiresAt: columnMap['expires_at'] as DateTime,
      );
    } on StateError catch (e, st) {
      throw CRSException(
        CRSExceptionType.ITEM_NOT_FOUND,
        'No publishing task found for id: $id',
        e,
        st,
      );
    }
  }

  @override
  FutureOr<PublishingTask> updatePublishingTaskStatus(
    String id, {
    required TaskStatus status,
    String? message,
  }) async {
    if (_statements['updatePublishingTaskStatus'] == null) {
      _statements['updatePublishingTaskStatus'] = await _pool.prepare(
        Sql.named('''
UPDATE package_publishing_tasks
SET status = @status, updated_at = @updatedAt, message = @message
WHERE id = @id
RETURNING *
'''),
      );
    }

    final result = await _statements['updatePublishingTaskStatus']!.run({
      'status': status.name,
      'id': id,
      'updatedAt': DateTime.now(),
      'message': message,
    });

    final columnMap = result.first.toColumnMap();
    final vcsUrl = columnMap['vcs_url'] as String?;

    return PublishingTask(
      id: columnMap['id'] as String,
      name: columnMap['name'] as String,
      scope: columnMap['scope'] as String?,
      message: columnMap['message'] as String?,
      status: TaskStatus.fromString(
        (columnMap['status'] as UndecodedBytes).asString,
      ),
      user: columnMap['user_id'] as String,
      version: columnMap['version'] as String,
      $new: columnMap['new'] as bool,
      language: columnMap['language'] as String,
      config: columnMap['config'] as String,
      configMap: columnMap['config_map'],
      metadata: columnMap['metadata'],
      env: (columnMap['env'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v is String ? v : v.toString()),
      ),
      vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
      vcsUrl: vcsUrl == null ? null : Uri.parse(vcsUrl),
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
      expiresAt: columnMap['expires_at'] as DateTime,
    );
  }

  @override
  Future<Package> changePackagePublicity(String name, {String? scope}) {
    // TODO: implement changePackagePublicity
    throw UnimplementedError();
  }

  @override
  FutureOr<Map<Package, Iterable<Privileges>>> getPackagesContributedToByUser(
    String id,
  ) async {
    if (_statements['getPackagesContributedToByUser'] == null) {
      _statements['getPackagesContributedToByUser'] = await _pool.prepare(
        Sql.named('''
SELECT p.id, p.name, p.scope, p.version, p.description, p.author_id, p.language, p.vcs, p.vcs_url, p.archive, p.license, p.public, p.created_at, p.updated_at,
       u.name AS author_name, u.email AS author_email, u.avatar_url AS author_avatar_url, u.created_at AS author_created_at, u.updated_at AS author_updated_at
       pc.privileges AS contributor_privileges
FROM package_contributors pc
INNER JOIN packages p ON pc.package_id = p.id
INNER JOIN users u ON p.author_id = u.id
WHERE pc.user_id = @userId
'''),
      );
    }

    final result = await _statements['getPackagesContributedToByUser']!.run({
      'userId': id,
    });

    return result.asMap().map((k, row) {
      final columnMap = row.toColumnMap();

      return MapEntry(
        Package(
          id: columnMap['id'] as String,
          name: columnMap['name'] as String,
          scope: columnMap['scope'] as String?,
          version: columnMap['version'] as String,
          description: columnMap['description'] as String?,
          author: User(
            id: id,
            name: columnMap['author_name'] as String,
            email: columnMap['author_email'] as String,
            createdAt: columnMap['author_created_at'] as DateTime,
            updatedAt: columnMap['author_updated_at'] as DateTime,
            avatarUrl: columnMap['author_avatar_url'] as String?,
          ),
          language: columnMap['language'] as String,
          vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
          vcsUrl: columnMap['vcs_url'] == null
              ? null
              : Uri.parse(columnMap['vcs_url'] as String),
          archive: Uri.parse(columnMap['archive'] as String),
          license: columnMap['license'] as String?,
          created: columnMap['created_at'] as DateTime,
          updated: columnMap['updated_at'] as DateTime,
          public: columnMap['public'] as bool?,
        ),
        (columnMap['contributor_privileges'] as Iterable<UndecodedBytes>).map(
          (privilege) => Privileges.fromString(privilege.asString),
        ),
      );
    });
  }

  @override
  Stream<(Package, Iterable<Privileges>)> getPackagesContributedToByUserStream(
    String id,
  ) async* {
    if (_statements['getPackagesContributedToByUser'] == null) {
      _statements['getPackagesContributedToByUser'] = await _pool.prepare(
        Sql.named('''
SELECT p.id, p.name, p.scope, p.version, p.description, p.author_id, p.language, p.vcs, p.vcs_url, p.archive, p.license, p.public, p.created_at, p.updated_at,
       u.name AS author_name, u.email AS author_email, u.avatar_url AS author_avatar_url, u.created_at AS author_created_at, u.updated_at AS author_updated_at
       pc.privileges AS contributor_privileges
FROM package_contributors pc
INNER JOIN packages p ON pc.package_id = p.id
INNER JOIN users u ON p.author_id = u.id
WHERE pc.user_id = @userId
'''),
      );
    }

    final result = _statements['getPackagesContributedToByUser']!.run({
      'userId': id,
    });

    // TODO: Stream.fromFuture or Stream.fromIterable?
    // Using Stream.fromFuture to ensure the result is awaited before streaming
    // and asyncExpand to handle the row mapping asynchronously.
    // This allows for better performance and avoids blocking the event loop.
    // If the result is large, consider using Stream.fromIterable directly.
    yield* Stream.fromFuture(result).asyncExpand((row) {
      return Stream.fromIterable(row).map((row) {
        final columnMap = row.toColumnMap();

        return (
          Package(
            id: columnMap['id'] as String,
            name: columnMap['name'] as String,
            scope: columnMap['scope'] as String?,
            version: columnMap['version'] as String,
            description: columnMap['description'] as String?,
            author: User(
              id: id,
              name: columnMap['author_name'] as String,
              email: columnMap['author_email'] as String,
              createdAt: columnMap['author_created_at'] as DateTime,
              updatedAt: columnMap['author_updated_at'] as DateTime,
              avatarUrl: columnMap['author_avatar_url'] as String?,
            ),
            language: columnMap['language'] as String,
            vcs: VCS.fromString((columnMap['vcs'] as UndecodedBytes).asString),
            vcsUrl: columnMap['vcs_url'] == null
                ? null
                : Uri.parse(columnMap['vcs_url'] as String),
            archive: Uri.parse(columnMap['archive'] as String),
            license: columnMap['license'] as String?,
            created: columnMap['created_at'] as DateTime,
            updated: columnMap['updated_at'] as DateTime,
            public: columnMap['public'] as bool?,
          ),
          (columnMap['contributor_privileges'] as Iterable<UndecodedBytes>).map(
            (privilege) => Privileges.fromString(privilege.asString),
          ),
        );
      });
    });
  }
}

extension Authorization on PrittDatabase {
  /// Check for the authorization of a user
  // TODO(nikeokoronkwo): Implement a better way to check for authorization, maybe put this behind a cache, https://github.com/nikeokoronkwo/pritt-dart/issues/31
  @Cacheable()
  Future<User?> checkAuthorization(
    String accessToken, {
    AccessTokenType? tokenType,
  }) async {
    bool noToken = false;

    // validate access token expiration
    if (accessToken.isEmpty) {
      throw UnauthorizedException('Access token is empty');
    }

    final result = await _pool.runTx((session) async {
      final rs = await session.execute(r'''SELECT hash FROM access_tokens''');
      final accessTokenHashes = rs.map((row) => row[0] as String);
      final successFullToken = accessTokenHashes.where(
        (hash) => auth.validateAccessToken(accessToken, hash),
      );
      if (successFullToken.isEmpty) {
        noToken = true;
      } else if (successFullToken.singleOrNull == null) {
        noToken = false;
      } else {
        return await session.execute(
          Sql.named('''
SELECT u.id, u.name, u.email, u.avatar_url, u.created_at, u.updated_at, a.token_type, a.expires_at as access_token_expires_at
FROM users u
INNER JOIN access_tokens a ON a.user_id = u.id
WHERE a.hash = @accessToken'''),
          parameters: {'accessToken': successFullToken.first},
        );
      }
    });

    if (result == null || result.isEmpty || noToken) {
      throw UnauthorizedException(
        'Invalid access token',
        type: UnauthorizedExceptionType.INVALID_TOKEN,
        token: accessToken,
      );
    }

    final row = result.first;
    final columnMap = row.toColumnMap();

    // if a token type is presented, validate the token type
    if (tokenType != null) {
      final targetTokenType = AccessTokenType.fromString(
        (columnMap['token_type'] as UndecodedBytes).asString,
      );
      if (targetTokenType != tokenType) {
        throw UnauthorizedException(
          'The device wanting to access with this access code is not authorized',
          type: UnauthorizedExceptionType.UNAUTHORIZED_DEVICE,
        );
      }
    }

    // check the access token expiration
    // TODO: Double check other details
    final expirationTime = columnMap['access_token_expires_at'] as DateTime;
    if (expirationTime.isBefore(DateTime.now())) {
      throw ExpiredTokenException(
        'Access token has expired',
        token: accessToken,
      );
    }

    final user = User(
      id: columnMap['id'] as String,
      name: columnMap['name'] as String,
      email: columnMap['email'] as String,
      avatarUrl: columnMap['avatar_url'] as String?,
      createdAt: columnMap['created_at'] as DateTime,
      updatedAt: columnMap['updated_at'] as DateTime,
    );

    return user;
  }
}

String generateRandomCode({int length = 8, String? seed}) {
  final random = Random.secure();

  final characters = 'ABCDEFGHJKLMNOPQRSTUVWXYZ234567890';

  final String input;
  if (seed == null) {
    input = characters;
  } else {
    var encodedSeed = base64Encode(utf8.encode(seed));
    input = encodedSeed.split('').where((c) => characters.contains(c)).join('');
  }

  StringBuffer output = StringBuffer();
  for (int i = 0; i < length; ++i) {
    output.write(input[random.nextInt(characters.length - 1)]);
  }

  return output.toString();
}
