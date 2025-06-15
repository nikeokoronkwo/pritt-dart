// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:typed_data';
import 'package:aws_s3_api/s3-2006-03-01.dart';
import '../crs/exceptions.dart';
import 'storage/interface.dart';

/// The current implementation of the CRS Object File Storage, used for storing package archives makes use of multiple backends, but basically make use of the [S3 API]().
/// During development, or docker compose deployments, we use [OpenIO]().
///
/// During live production deployments (usually not on prem), we make use of &lt;insert cloud provider S3 compatible OFS here&gt;
class PrittStorage implements PrittStorageInterface<Bucket> {
  PrittStorage._();

  @override
  Bucket pkgBucket;

  @override
  Bucket publishingBucket;

  @override
  Bucket adapterBucket;

  S3 get s3Instance {
    if (PrittStorage.s3 != null) return PrittStorage.s3!;
    throw Exception('S3 not initialised');
  }

  static S3? s3;

  static Future<({Bucket pkg, Bucket pub})> initialiseS3(String url,
      {required String region,
      required String accessKey,
      required String secretKey}) async {
    s3 = S3(
      region: region,
      credentials:
          AwsClientCredentials(accessKey: accessKey, secretKey: secretKey),
      endpointUrl: url,
    );

    final s3PkgBucket = (await s3!.listBuckets())
            .buckets
            ?.where((b) => b.name == 'pritt-packages') ??
        [];
    if (s3PkgBucket.isEmpty) {
      await s3!.createBucket(
        bucket: 'pritt-packages',
      );
    }

    final s3PubBucket = (await s3!.listBuckets())
            .buckets
            ?.where((b) => b.name == 'pritt-publishing-archives') ??
        [];
    if (s3PkgBucket.isEmpty) {
      await s3!.createBucket(
        bucket: 'pritt-packages',
      );
    }

    return s3!;
  }

  static Future<PrittStorage> connect(String url,
      {String? s3region, String? s3accessKey, String? s3secretKey}) async {
    s3region ??= String.fromEnvironment('S3_REGION');
    s3secretKey ??= String.fromEnvironment('S3_SECRET_KEY');
    s3accessKey ??= String.fromEnvironment('S3_ACCESS_KEY');

    if (s3 == null) {
      await initialiseS3(url,
          region: s3region, accessKey: s3accessKey, secretKey: s3secretKey);
    }

    return PrittStorage._();
  }

  @override
  FutureOr copyPackage(String from, String to) async {
    // copy the object from one path to another
    if (from == to) {
      return;
    }

    // Get the object from the bucket
    final object = await s3Instance.getObject(
      bucket: "pritt-packages",
      key: from,
    );

    // Create the object in the bucket
    final upload = await s3Instance.putObject(
      bucket: "pritt-packages",
      key: to,
      body: object.body,
      contentType: object.contentType,
      metadata: object.metadata,
    );

    // TODO: implement copy
    throw UnimplementedError();
  }

  @override
  Future<bool> createPackage(String path, Uint8List data, String sha,
      {String? contentType, Map<String, String>? metadata}) async {
    // upload the file to the S3 bucket

    // Create the object in the bucket
    final upload = await s3Instance.putObject(
      bucket: "pritt-packages",
      key: path,
      body: data,
      contentType: contentType,
      metadata: {
        'sha256': sha,
      }..addAll(metadata ?? {}),
    );

    return true;
  }

  @override
  Future<CRSFile?> findPackage(String path) async {
    // list all objects in the bucket at a directory
    final list = await s3Instance.listObjectsV2(
      bucket: "pritt-packages",
      prefix: path,
    );

    var file = list.contents?.firstWhere((e) => e.key == path);
    return file == null
        ? null
        : CRSFile(
            path: path, lastModified: file.lastModified, size: file.size ?? 0);
    // TODO: implement list
  }

  @override
  Future<List<CRSFile>> listAllPackages() async {
    final list = await s3Instance.listObjectsV2(
      bucket: "pritt-packages",
    );

    return list.contents
            ?.map((e) => CRSFile(
                path: e.key!, lastModified: e.lastModified, size: e.size ?? 0))
            .toList() ??
        [];
  }

  @override
  Future<List<CRSFile>> listPackagesWhere(
      bool Function(String path) where) async {
    final list = await s3Instance.listObjectsV2(
      bucket: "pritt-packages",
    );

    return list.contents
            ?.where((e) => where(e.key ?? ''))
            .map((e) => CRSFile(
                path: e.key!, lastModified: e.lastModified, size: e.size ?? 0))
            .toList() ??
        [];
  }

  @override
  FutureOr removePackage(String path) async {
    // remove the object from the bucket
    final deletion = await s3Instance.deleteObject(
      bucket: "pritt-packages",
      key: path,
    );

    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  FutureOr updatePackage(String path, Uint8List data) async {
    final original = await s3Instance.getObject(
      bucket: "pritt-packages",
      key: path,
    );

    final upload = await s3Instance.putObject(
      bucket: "pritt-packages",
      key: path,
      body: data,
      contentType: original.contentType,
      metadata: original.metadata,
    );
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<CRSFileOutputStream> getPackage(String path) async {
    // get the object from the bucket
    final object = await s3Instance.getObject(
      bucket: "pritt-packages",
      key: path,
    );

    if (object.body == null) {
      throw CRSException(
          CRSExceptionType.OBJECT_NOT_FOUND, 'Could not find archive at $path');
    }

    // return the object as a CRSFileOutputStream
    return CRSFileOutputStream(
      path: path,
      data: object.body!,
      metadata: object.metadata ?? {},
      contentType: object.contentType,
      size: object.contentLength ?? 0,
      hash: object.metadata?['sha256'] ?? '',
      signature: object.metadata?['signature'] ?? '',
      integrity: object.metadata?['integrity'] ?? '',
    );
  }

  @override
  FutureOr createPubArchive(String path, Uint8List data, String sha, {String? contentType, Map<String, String>? metadata}) {
    // TODO: implement createPubArchive
    throw UnimplementedError();
  }

  @override
  FutureOr<CRSFileOutputStream> getPubArchive(String path) {
    // TODO: implement getPubArchive
    throw UnimplementedError();
  }

  @override
  FutureOr movePubArchiveToPackage(String from, String to) {
    // TODO: implement movePubArchiveToPackage
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> pubArchiveExists(String path) {
    // TODO: implement pubArchiveExists
    throw UnimplementedError();
  }

  @override
  FutureOr removePubArchive(String path) {
    // TODO: implement removePubArchive
    throw UnimplementedError();
  }
}
