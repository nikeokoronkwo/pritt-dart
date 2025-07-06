import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pritt_common/version.dart';

import '../../../pritt_server.dart';
import '../base/db/schema.dart';
import '../base/task_manager.dart';
import 'interfaces.dart';

final publishingTaskRunner =
    TaskRunner<PubTaskItem, Archive, void, Map<String, dynamic>>(
      debug: true,
      retryInterval: Duration(milliseconds: 800),
      onRetrieve: getTarballForTask,
      workAction: processTarball,
      onCheck: checkTarballStatus,
      context: {
        'createPackageVersionFromPublishingTask':
            (
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
            }) => crs.db.createPackageVersionFromPublishingTask(
              id,
              versionType: versionType,
              readme: readme,
              description: description,
              rawConfig: rawConfig,
              info: info,
              archive: archive,
              hash: hash,
              signatures: signatures,
              integrity: integrity,
              task: task,
              contributorIds: contributorIds,
            ),
        'createPackageFromPublishingTask':
            (
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
            }) => crs.db.createPackageFromPublishingTask(
              id,
              versionType: versionType,
              readme: readme,
              description: description,
              license: license,
              rawConfig: rawConfig,
              info: info,
              archive: archive,
              hash: hash,
              signatures: signatures,
              integrity: integrity,
              task: task,
              contributorIds: contributorIds,
            ),
      },
    );

/// Processes the tarball
FutureOr<void> processTarball(
  WorkerItem<PubTaskItem, Archive, Map<String, dynamic>> item,
) async {
  // TODO(nikeokoronkwo): Temporary fix for isolate discovery of variables
  //  in reality, we should try to minimize the number of connections at a time to allow more concurrent queue tasks
  //  which would require a reworking of the worker's serialization
  await startPrittServices(customAdapters: false);

  // get task info
  final taskInfo = await item.task.taskInfo;

  // open tarball archive
  final archive = item.resource;
  final configName = taskInfo.config.toLowerCase();

  if (archive.isEmpty) {
    throw Exception('Empty tarball');
  }

  ArchiveFile? readme;
  ArchiveFile configFile = archive.firstWhere(
    (f) =>
        f.isFile &&
        p.basename(f.name.toLowerCase()) == configName.toLowerCase(),
  );
  // TODO(nikeokoronkwo): Incorporate files and file checks: changelog (changelog map), license, pritt config (contributors)
  // ArchiveFile? changelog, license, prittConfig;

  for (final file in archive) {
    if (!file.isFile) break;

    final fileName = file.name;
    switch (p.basenameWithoutExtension(fileName.toLowerCase())) {
      case 'readme':
        readme = file;
        break;
      case 'changelog':
        // changelog = file;
        break;
      case 'license':
        // license = file;
        break;
      case 'pritt':
        // prittConfig = file;
        break;
      default:
        if (p.basenameWithoutExtension(fileName.toLowerCase()) == configName) {
          configFile = file;
        }
        break;
    }
  }

  // process readme

  // process changelog

  // process license

  // read pritt config (future)

  // zip up tarball
  // tarballData should not be null, else worker will fail before now
  var tarballData = GZipEncoder().encode(TarEncoder().encode(archive))!;

  var archiveParts = [
    if (taskInfo.scope != null) '@${taskInfo.scope}',
    taskInfo.name,
    taskInfo.version,
  ];

  final tarballPath = '${archiveParts.join('/')}.tar.gz';

  final tarballDigest = sha256.convert(tarballData);

  // create hash
  final tarballHash = tarballDigest.toString();
  // create signature
  final tarballIntegrity = 'sha256-${base64.encode(tarballDigest.bytes)}';

  // TODO: Signatures: https://pub.dev/packages/cryptography
  // TODO: info population

  if (taskInfo.$new) {
    // create new package, if not exists
    await crs.db.createPackageFromPublishingTask(
      item.task.id,
      license: 'not detected',
      readme: readme?.content == null
          ? null
          : base64.encode(readme?.content as Uint8List),
      rawConfig: utf8.decode(configFile.content),
      archive: Uri.file(tarballPath, windows: false),
      hash: tarballHash,
      integrity: tarballIntegrity,
    );
  } else {
    // create new package version
    await crs.db.createPackageVersionFromPublishingTask(
      item.task.id,
      readme: readme?.content == null
          ? null
          : base64.encode(readme?.content as Uint8List),
      rawConfig: configFile.content,
      archive: Uri.file(tarballPath, windows: false),
      hash: tarballHash,
      integrity: tarballIntegrity,
    );
  }

  // prepare for upload

  // add to storage
  await crs.ofs
      .createPackage(
        tarballPath,
        Uint8List.fromList(tarballData),
        tarballHash,
        contentType: 'application/gzip',
        metadata: {'integrity': tarballIntegrity},
      )
      .then((_) async {
        // remove pub tarball afterwards
        await crs.ofs.removePubArchive('${archiveParts.join('-')}.tar.gz');
      });
}

// TODO(nikeokoronkwo): The call to `getPublishingTaskById` is marked with `@Cacheable`
//  caching this call would be very helpful, https://github.com/nikeokoronkwo/pritt-dart/issues/31
FutureOr<Archive?> getTarballForTask(PubTaskItem item) async {
  // get task details from db
  final taskInfo = await item.taskInfo;

  if (taskInfo.tarball != null) {
    // get url and use `http` to check manually
    try {
      final response = await http.get(taskInfo.tarball!);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Save to disk or memory cache
        final archive = TarDecoder().decodeBytes(
          GZipDecoder().decodeBytes(bytes),
        );

        return archive;
      } else {
        throw Exception('Failed to retrieve tarball: ${response.statusCode}');
      }
    } catch (_) {
      return null;
    }
  } else {
    // use info to check storage S3
    var archiveNameParts = [
      if (taskInfo.scope != null) '@${taskInfo.scope}',
      taskInfo.name,
      taskInfo.version,
    ];

    print('${archiveNameParts.join('-')}.tar.gz');

    try {
      final output = await crs.ofs.getPubArchive(
        '${archiveNameParts.join('-')}.tar.gz',
      );

      final archive = TarDecoder().decodeBytes(
        GZipDecoder().decodeBytes(output.data),
      );

      return archive;
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      return null;
    }
  }
}

/// Checks the status of the tarball without downloading it
FutureOr<bool> checkTarballStatus(PubTaskItem item) async {
  // get task details from db
  final taskInfo = await item.taskInfo;
  if (taskInfo.tarball != null) {
    // get url and use `http` to check manually
    final response = await http.head(taskInfo.tarball!);

    return response.statusCode == 200;
  } else {
    // use info to check storage S3
    var archiveNameParts = [
      if (taskInfo.scope != null) '@${taskInfo.scope}',
      taskInfo.name,
      taskInfo.version,
    ];

    print('${archiveNameParts.join('-')}.tar.gz');
    return await crs.ofs.pubArchiveExists(
      '${archiveNameParts.join('-')}.tar.gz',
    );
  }
}
