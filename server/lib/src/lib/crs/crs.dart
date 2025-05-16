// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:postgres/postgres.dart';
import 'package:pritt_server/src/lib/crs/db.dart';
import 'package:pritt_server/src/lib/crs/db/schema.dart';
import 'package:pritt_server/src/lib/crs/fs.dart';
import 'package:pritt_server/src/lib/shared/version.dart';

/// The core registry service
///
/// This is a service that contains the package-manager agnostic (matter of fact, environment agnostic) info about packages in the Pritt Registry
///
/// It connects to the database and the object file storage via a pool of resources (i.e makes multiple concurrent requests capped at a maximum) and provides access to data in the
class CoreRegistryService {}
