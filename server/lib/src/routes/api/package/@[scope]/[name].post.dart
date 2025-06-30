import 'dart:convert';

import 'package:pritt_common/functions.dart';
import 'package:pritt_common/interface.dart' as common;

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
  final pkgScope = getParams(event, 'scope') as String;

  try {
    // check if user is authenticated
    var authHeader = getHeader(event, 'Authorization');
    var user = authHeader == null ? null : await checkAuthorization(authHeader);

    if (user == null) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(error: 'UnauthorizedError').toJson();
    }

    // check if user is in scope
    final members = crs.db.getMembersForOrganizationStream(pkgScope);
    if (!(await members.contains(user))) {
      setResponseCode(event, 401);
      return common.UnauthorizedError(
              error: 'UnauthorizedError', reason: common.UnauthorizedReason.org)
          .toJson();
    }

    final body = await getBody(
        event, (s) => common.PublishPackageRequest.fromJson(json.decode(s)));

    // from info...
    // get pkg name, pkg version

    // get pkg pritt config, if any
    // TODO: Pritt Configuration

    // check if package exists
    try {
      final pkg = await crs.db
          .getPackage(pkgName, scope: pkgScope, language: body.language);

      // package exists
      // if it does, throw error
      setResponseCode(event, 400);
      return common.ExistsError(name: scopedName(body.name, body.scope))
          .toJson();
    } catch (_) {
      // continue
    }

    // TODO: Contributors
    final pubTask = await crs.db.createNewPublishingTask(
        name: pkgName,
        scope: pkgScope,
        version: body.version,
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
  } on CRSException catch (e) {
    switch (e.type) {
      case CRSExceptionType.SCOPE_NOT_FOUND:
        setResponseCode(event, 404);
        return common.NotFoundError(error: 'The given scope $pkgScope could not be found. You will need to create the scope first');
      default:
        setResponseCode(event, 500);
        return common.ServerError(error: 'Server Error').toJson();
    }
  } catch (e) {
    setResponseCode(event, 500);
    return common.ServerError(error: 'Server Error').toJson();
  }
});
