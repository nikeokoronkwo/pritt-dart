// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'dart:typed_data';

import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/fs.dart';

/// The current implementation of the CRS Database makes use of [postgresql](https://www.postgresql.org/)
/// via the [postgres](https://pub.dev/packages/postgres) package
///
/// It uses a connection Pool to handle multiple requests
///
/// For more information on the APIs used in this class, see [CRSDatabaseInterface]
class CRSDatabase implements CRSDatabaseInterface {}

/// The current implementation of the CRS Object File Storage, used for storing package archives makes use of multiple backends, but basically make use of the [S3 API]().
/// During development, or docker compose deployments, we use [OpenIO]().
///
/// During live production deployments (usually not on prem), we make use of &lt;insert cloud provider S3 compatible OFS here&gt;
class CRSStorage implements CRSRegistryOFSInterface {
  @override
  FutureOr copy(String from, String to) {
    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  FutureOr create(String path, Uint8List data, String sha) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  FutureOr list(String path) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  FutureOr listAll() {
    // TODO: implement listAll
    throw UnimplementedError();
  }

  @override
  FutureOr listWhere(bool Function(String path) where) {
    // TODO: implement listWhere
    throw UnimplementedError();
  }

  @override
  FutureOr remove(String path) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  FutureOr update(String path, Uint8List data) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

/// The core registry service
///
/// This is a service that contains the package-manager agnostic (matter of fact, environment agnostic) info about packages in the Pritt Registry
///
/// It connects to the database and the object file storage via a pool of resources (i.e makes multiple concurrent requests capped at a maximum) and provides access to data in the
class CoreRegistryService {}
