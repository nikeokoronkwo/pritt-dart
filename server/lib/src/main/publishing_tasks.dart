import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pritt_common/functions.dart';

import '../../pritt_server.dart';
import 'base/db/schema.dart';
import 'base/task_manager.dart';

class PubTaskItem extends TaskBase {
  @override
  String id;

  PublishingTask? _savedTask;
  TaskStatus _status = TaskStatus.queue;

  FutureOr<PublishingTask> get taskInfo async =>
      _savedTask ?? await crs.db.getPublishingTaskById(id);

  @override
  TaskStatus get status => _status;

  @override
  FutureOr<void> updateStatus(TaskStatus newStatus) async {
    _savedTask = await crs.db.updatePublishingTaskStatus(id, status: status);
    _status = newStatus;
  }

  PubTaskItem(this.id);

  @override
  void updateError(Object error) {
    // TODO: Implement updateError
    // if (error is Exception) {
    //
    // }
  }
}

final publishingTaskRunner = TaskRunner<PubTaskItem, Archive, void>(
    retryInterval: Duration(seconds: 1), // TODO: Get better time via testing
    onRetrieve: getTarballForTask,
    workAction: processTarball,
    onCheck: checkTarballStatus);

// TODO: The call to `getPublishingTaskById` is marked with `@Cacheable`
//  caching this call would be very helpful
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
        final archive =
            TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

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
      taskInfo.version
    ];

    try {
      final output =
          await crs.ofs.getPubArchive('${archiveNameParts.join('-')}.tar.gz');

      final archive =
          TarDecoder().decodeBytes(GZipDecoder().decodeBytes(output.data));

      return archive;
    } catch (_) {
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
      taskInfo.version
    ];
    return await crs.ofs
        .pubArchiveExists('${archiveNameParts.join('-')}.tar.gz');
  }
}

/// Processes the tarball
FutureOr<void> processTarball(WorkerItem<PubTaskItem, Archive> item) async {
  // get task info
  final taskInfo = await item.task.taskInfo;

  // open tarball archive
  final archive = item.resource;
  final configName = taskInfo.config.toLowerCase();
  final pkgName = scopedName(taskInfo.name, taskInfo.scope);

  if (archive.isEmpty) {
    throw Exception('Empty tarball');
  }

  // check tarball size is on limits (double check)
  // TODO: such check should be done on upload side
  ArchiveFile? readme;
  ArchiveFile configFile = archive.firstWhere((f) =>
      f.isFile &&
      p.basenameWithoutExtension(f.name.toLowerCase()) == configName);
  ArchiveFile? changelog;
  ArchiveFile? license;
  ArchiveFile? prittConfig;

  for (final file in archive) {
    if (!file.isFile) break;

    final fileName = file.name;
    switch (p.basenameWithoutExtension(fileName.toLowerCase())) {
      case 'readme':
        readme = file;
        break;
      case 'changelog':
        changelog = file;
        break;
      case 'license':
        license = file;
        break;
      case 'pritt':
        prittConfig = file;
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
    taskInfo.version
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
    final (Package pkg, PackageVersions pkgVer) =
        await crs.db.createPackageFromPublishingTask(
      item.task.id,
      license: 'not detected',
      readme: readme?.content == null
          ? null
          : base64.encode(utf8.encode(readme?.content)),
      rawConfig: configFile.content,
      archive: Uri.file(tarballPath, windows: false),
      hash: tarballHash,
      integrity: tarballIntegrity,
    );
  } else {
    // create new package version
    final pkgVer = await crs.db.createPackageVersionFromPublishingTask(
      item.task.id,
      readme: readme?.content == null
          ? null
          : base64.encode(utf8.encode(readme?.content)),
      rawConfig: configFile.content,
      archive: Uri.file(tarballPath, windows: false),
      hash: tarballHash,
      integrity: tarballIntegrity,
    );
  }

  // prepare for upload

  // add to storage
  await crs.ofs.createPackage(
      tarballPath, Uint8List.fromList(tarballData), tarballHash,
      contentType: 'application/gzip',
      metadata: {
        'integrity': tarballIntegrity,
      }).then((_) async {
    // remove pub tarball afterwards
    await crs.ofs.removePubArchive('${archiveParts.join('-')}.tar.gz');
  });
}
