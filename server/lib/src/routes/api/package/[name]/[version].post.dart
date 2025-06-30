import 'dart:convert';

import 'package:pritt_common/interface.dart' as common;
import 'package:pritt_common/version.dart';

import '../../../../../pritt_server.dart';
import '../../../../main/base/db/schema.dart';
import '../../../../main/crs/exceptions.dart';
import '../../../../main/publishing/interfaces.dart';
import '../../../../main/publishing/tasks.dart';
import '../../../../server_utils/authorization.dart';
import '../../../../utils/request_handler.dart';

final handler = defineRequestHandler((event) async {
  // parse info
  final pkgName = getParams(event, 'name') as String;
  final pkgVer = Version.parse(getParams(event, 'version') as String);

  try {
    // check if user is authenticated
    var authHeader = getHeader(event, 'Authorization');
    var user = authHeader == null ? null : await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    // get pkg
    final pkg = await crs.db.getPackage(pkgName);

    if (pkg.author.id != user.id) {
      // check if user is contrib to the package
      final contributors = await crs.db.getContributorsForPackage(pkgName);
      if (!(contributors.keys.any((k) => k.id == user.id))) {
        // unauthorized
        setResponseCode(event, 401);
        return common.UnauthorizedError(
                error: 'UnauthorizedError',
                reason: common.UnauthorizedReason.package_access)
            .toJson();
      }
    }

    final body = await getBody(event,
        (s) => common.PublishPackageByVersionRequest.fromJson(json.decode(s)));

    assert(body.scope == null,
        "Use /api/package/@:scope/:name/:version for scoped packages");

    // from info...
    // get pkg name, pkg version

    // get pkg pritt config, if any
    // TODO: Pritt Configuration

    // check if package exists
    try {
      final _ = await crs.db.getPackageWithVersion(pkgName, pkgVer);

      // package exists
      // if it does, throw error
      setResponseCode(event, 400);
      return common.ExistsError(name: body.name).toJson();
    } catch (_) {
      // continue
    }

    // TODO: Contributors
    final pubTask = await crs.db.createNewPublishingTask(
        name: pkgName,
        version: pkgVer.toString(),
        user: user,
        language: body.language,
        newPkg: true,
        config: body.config.path,
        configData: body.config.config ?? {},
        metadata: body.info,
        env: body.env
            ?.map((k, v) => MapEntry(k, v is String ? v : v.toString())),
        vcs: body.vcs == null
            ? null
            : switch (body.vcs!.name) {
                common.VCS.git => VCS.git,
                common.VCS.svn => VCS.svn,
                common.VCS.fossil => VCS.fossil,
                common.VCS.mercurial => VCS.mercurial,
                common.VCS.other => VCS.other,
              },
        vcsUrl: body.vcs?.url);

    // add package queue task
    publishingTaskRunner.addTask(PubTaskItem(pubTask.id));

    // TODO: Create upload URL for S3

    // send details down
    return common.PublishPackageResponse(
            queue: common.Queue(
                id: pubTask.id, status: common.PublishingStatus.queue))
        .toJson();
  } on AssertionError catch (e) {
    setResponseCode(event, 400);
    return common.UnauthorizedError(
            error: e.message.toString(),
            reason: common.UnauthorizedReason.org)
        .toJson();
  } on TypeError {
    setResponseCode(event, 400);
    return common.Error(error: 'InvalidBody').toJson();
  } on CRSException catch (e, st) {
    switch (e.type) {
      case CRSExceptionType.PACKAGE_NOT_FOUND:
        setResponseCode(event, 403);
        print('${e.stackTrace} :: $st');
        return common.Error(error: 'Error: ${e.message}: Instead, call')
            .toJson();
      default:
    }
  } catch (e, st) {
    setResponseCode(event, 500);
    print('$e: $st');
    return common.ServerError(error: 'Server Error').toJson();
  }
});
