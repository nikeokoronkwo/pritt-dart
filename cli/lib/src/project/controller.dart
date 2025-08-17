import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pritt_common/config.dart' as config;
import 'package:pritt_common/interface.dart';
import 'package:yaml/yaml.dart';

import '../adapters/base.dart';
import '../adapters/base/config.dart';
import '../adapters/base/controller.dart';
import '../client.dart';
import '../client/authentication.dart';
import '../constants.dart';
import '../loader.dart';
import '../utils/annotations.dart';
import '../utils/typedefs.dart';
import 'exception.dart';

class PrittControllerManager {
  final PrittClient? apiClient;
  final String? dir;
  final String? prittConfigFileName;
  final config.PrittConfig? prittConfig;

  const PrittControllerManager({
    this.apiClient,
    this.dir,
    this.prittConfigFileName,
    this.prittConfig,
  }) : assert(
         prittConfigFileName == null || prittConfig != null,
         'prittConfigFileName or prittConfig must either be both provided, or both null',
       );

  PrittConfigUnawareController makeConfigUnawareController(Handler handler) {
    return PrittConfigUnawareController(
      configLoader: handler.config,
      client: apiClient,
      prittConfigFileName: prittConfigFileName,
    );
  }

  PrittController<T> makeController<T extends Config>(Handler<T> handler) {
    // create first
    final configUnawareCtrl = PrittConfigUnawareController(
      configLoader: handler.config,
      client: apiClient,
      prittConfigFileName: prittConfigFileName,
    );

    Future<T> converter(String contents) async {
      return await handler.onGetConfig(dir ?? p.current, configUnawareCtrl);
    }

    return configUnawareCtrl._upgrade(convertConfig: converter);
  }
}

class PrittConfigUnawareController
    implements PrittLocalConfigUnawareController {
  Loader<String, String> configLoader;
  PrittClient? client;
  String? token;

  String? prittConfigFileName;
  final config.PrittConfig? prittConfig;

  PrittConfigUnawareController({
    required this.configLoader,
    this.client,
    String? token,
    this.prittConfigFileName = 'pritt.yaml',
    this.prittConfig,
  }) : token =
           token ?? (client?.authentication as HttpBearerAuth?)?.accessToken;

  PrittController<T> _upgrade<T extends Config>({
    required FutureOr<T> Function(String) convertConfig,
  }) {
    return PrittController(
      convertConfig: convertConfig,
      configLoader: configLoader,
      client: client,
    );
  }

  @override
  Future<bool> fileExists(String path, {String? cwd}) {
    return File(p.join(cwd ?? p.current, path)).exists();
  }

  @override
  @localCacheable
  FutureOr<Author> getCurrentAuthor() async {
    final user = await getCurrentUser();
    return Author(name: user.name, email: user.email);
  }

  @override
  @localCacheable
  FutureOr<User> getCurrentUser() async {
    if (client == null) {
      throw AuthorizationException(
        'The current adapter needs user credentials, but user not logged in',
      );
    }

    return await client!.getCurrentUser();
  }

  @override
  Stream<String> listFilesAt(String directory, {bool deep = false}) {
    return Directory(directory).list().map((a) => a.path);
  }

  @override
  List<String> listFilesAtSync(String directory, {bool deep = false}) {
    return Directory(directory).listSync().map((a) => a.path).toList();
  }

  @override
  void log(Object msg) => print(msg);

  @override
  FutureOr<String> readConfigFile(String directory) async {
    final configName = configLoader.name;
    final configContents = await File(
      p.join(directory, configName),
    ).readAsString();
    return configLoader.load(configContents);
  }

  @override
  String readConfigFileSync(String directory) {
    final configName = configLoader.name;
    final configContents = File(
      p.join(directory, configName),
    ).readAsStringSync();
    return configLoader.load(configContents);
  }

  @override
  Future<String> readFileAt(String path, {String? cwd}) {
    return File(p.join(cwd ?? p.current, path)).readAsString();
  }

  @override
  String readFileAtSync(String path, {String? cwd}) {
    return File(p.join(cwd ?? p.current, path)).readAsStringSync();
  }

  @override
  String configFileName() => configLoader.name;

  @override
  Future<String> run(
    String command, {
    List<String> args = const [],
    String? directory,
    Map<String, String>? environment,
  }) async {
    return (await Process.run(
      command,
      args,
      workingDirectory: directory,
      environment: (environment ?? {})
        ..addAll(Platform.environment)
        ..addAll({if (token != null) 'PRITT_AUTH_TOKEN': token!}),
    )).stdout;
  }

  @override
  FutureOr<String> readPrittConfigFile(String directory) {
    return readFileAt(p.join(directory, prittConfigFileName));
  }

  @override
  String readPrittConfigFileSync(String directory) {
    return readFileAtSync(p.join(directory, prittConfigFileName));
  }

  @override
  config.PrittConfig? getPrittConfig() {
    try {
      return prittConfig ??
          config.PrittConfig.fromJson(
            loadYaml(readPrittConfigFileSync(p.current)),
          );
    } catch (_) {
      return null; // If the file doesn't exist or is invalid, return null
    }
  }
}

class PrittController<T extends Config> extends PrittConfigUnawareController
    implements PrittLocalController {
  Loader<FutureOr<T>, String> builtConfigLoader;
  Loader<FutureOr<T>, String> convertConfigLoader;

  PrittClient? apiClient;

  PrittController({
    required FutureOr<T> Function(String) convertConfig,
    required super.configLoader,
    required PrittClient? client,
    super.prittConfigFileName,
  }) : apiClient = client,
       builtConfigLoader = configLoader.stack(convertConfig),
       convertConfigLoader = Loader(configLoader.name, load: convertConfig);

  @override
  FutureOr<T> getConfiguration(String directory) async {
    return await convertConfigLoader.load(await readConfigFile(directory));
  }

  @override
  String get instanceUri => apiClient?.url ?? mainPrittApiInstance;

  @override
  Future<void> writeFileAt(String path, String contents, {String? cwd}) async {
    await File(p.joinAll([if (cwd != null) cwd, path])).writeAsString(contents);
  }
}
