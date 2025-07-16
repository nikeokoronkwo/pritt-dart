// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:aws_s3_api/s3-2006-03-01.dart';
import 'package:aws_signer_api/signer-2017-08-25.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

import '../crs/exceptions.dart';
import 'storage/interface.dart';

/// The current implementation of the CRS Object File Storage, used for storing package archives makes use of multiple backends,
/// but basically make use of the [S3 API](https://docs.aws.amazon.com/AmazonS3/latest/API/Type_API_Reference.html).
/// During development, docker compose deployments, or on-prem if desired, we use [MinIO](https://min.io).
///
/// During live production deployments (usually not on prem), we make use of &lt;insert cloud provider S3 compatible OFS here&gt;
///
// TODO: In the future, we should make our own `PrittBucket` type that can wrap different buckets.
//  That way it is easier to use various other types of buckets if needed
class PrittStorage implements PrittStorageInterface<Bucket> {
  PrittStorage._({
    required this.pkgBucket,
    required this.publishingBucket,
    required this.adapterBucket,
    required this.url,
    required this.signer,
  });

  @override
  Bucket pkgBucket;

  @override
  Bucket publishingBucket;

  @override
  Bucket adapterBucket;

  String url;

  Signer signer;

  S3 get s3Instance {
    if (PrittStorage.s3 != null) return PrittStorage.s3!;
    throw Exception('S3 not initialised');
  }

  static S3? s3;

  static Future<({Bucket pkg, Bucket pub, Bucket adapter})> initialiseS3(
    String url, {
    required String region,
    required String accessKey,
    required String secretKey,
  }) async {
    s3 = S3(
      region: region,
      credentials: AwsClientCredentials(
        accessKey: accessKey,
        secretKey: secretKey,
      ),
      endpointUrl: url,
    );

    const r = RetryOptions(maxAttempts: 8);

    // let's perform a health check
    // prefer to do one request rather than three HEAD requests
    final s3BucketsResponse = await r.retry(
      () => s3!.listBuckets(),
      retryIf: (e) => e is http.ClientException || e is SocketException,
    );

    var s3Buckets = s3BucketsResponse.buckets ?? [];

    // check if needed buckets already exist
    if (!s3Buckets.any((b) => b.name == 'pritt-packages')) {
      await s3!.createBucket(bucket: 'pritt-packages');
    }
    if (!s3Buckets.any((b) => b.name == 'pritt-publishing-archives')) {
      await s3!.createBucket(bucket: 'pritt-publishing-archives');
    }
    if (!s3Buckets.any((b) => b.name == 'pritt-adapters')) {
      await s3!.createBucket(bucket: 'pritt-adapters');
    }

    // lets not call this whenever, only when needed
    s3Buckets = (await s3!.listBuckets()).buckets ?? [];

    // get buckets
    final s3PkgBucket = s3Buckets.firstWhere((b) => b.name == 'pritt-packages');
    final s3PubBucket = s3Buckets.firstWhere(
      (b) => b.name == 'pritt-publishing-archives',
    );
    final s3AdapterBucket = s3Buckets.firstWhere(
      (b) => b.name == 'pritt-adapters',
    );

    return (pkg: s3PkgBucket, pub: s3PubBucket, adapter: s3AdapterBucket);
  }

  static Future<PrittStorage> connect(
    String url, {
    String? s3region,
    String? s3accessKey,
    String? s3secretKey,
  }) async {
    s3region ??= Platform.environment['S3_REGION'] ?? 'us-east-1';
    s3secretKey ??=
        Platform.environment['S3_SECRET_KEY'] ??
        const String.fromEnvironment('S3_SECRET_KEY');
    s3accessKey ??=
        Platform.environment['S3_ACCESS_KEY'] ??
        const String.fromEnvironment('S3_ACCESS_KEY');

    final signer = Signer(
      region: s3region,
      credentials: AwsClientCredentials(
        accessKey: s3accessKey,
        secretKey: s3secretKey,
      ),
      endpointUrl: url,
    );

    if (s3 == null) {
      final (
        pkg: pkgBucket,
        pub: pubBucket,
        adapter: adapterBucket,
      ) = await initialiseS3(
        url,
        region: s3region,
        accessKey: s3accessKey,
        secretKey: s3secretKey,
      );

      return PrittStorage._(
        pkgBucket: pkgBucket,
        publishingBucket: pubBucket,
        adapterBucket: adapterBucket,
        url: url,
        signer: signer,
      );
    } else {
      final s3Buckets = (await s3!.listBuckets()).buckets ?? [];
      final s3PkgBucket = s3Buckets.firstWhere(
        (b) => b.name == 'pritt-packages',
      );
      final s3PubBucket = s3Buckets.firstWhere(
        (b) => b.name == 'pritt-publishing-archives',
      );
      final s3AdapterBucket = s3Buckets.firstWhere(
        (b) => b.name == 'pritt-adapters',
      );

      return PrittStorage._(
        pkgBucket: s3PkgBucket,
        publishingBucket: s3PubBucket,
        adapterBucket: s3AdapterBucket,
        url: url,
        signer: signer,
      );
    }
  }

  @override
  FutureOr copyPackage(String from, String to) async {
    // copy the object from one path to another
    if (from == to) {
      return;
    }

    // Get the object from the bucket
    final object = await s3Instance.getObject(
      bucket: pkgBucket.name ?? "pritt-packages",
      key: from,
    );

    // Create the object in the bucket
    final _ = await s3Instance.putObject(
      bucket: pkgBucket.name ?? "pritt-packages",
      key: to,
      body: object.body,
      contentType: object.contentType,
      metadata: object.metadata,
    );

    return;
  }

  @override
  Future<bool> createPackage(
    String path,
    Uint8List data,
    String sha, {
    String? contentType,
    Map<String, String>? metadata,
    bool private = false,
  }) async {
    // Create the object in the bucket
    try {
      final _ = await s3Instance.putObject(
        bucket: pkgBucket.name ?? "pritt-packages",
        key: path,
        body: data,
        contentType: contentType,
        metadata: {'sha256': sha}..addAll(metadata ?? {}),
        acl: private ? ObjectCannedACL.private : null,
      );

      return true;
    } on NoSuchBucket catch (e) {
      throw CRSException(
        CRSExceptionType.CRITICAL_ERROR,
        e.message ?? 'The bucket for pritt packages does not exist',
      );
    } on Exception {
      return false;
    }
  }

  @override
  Future<CRSFile?> findPackage(String path) async {
    // list all objects in the bucket at a directory
    try {
      final list = await s3Instance.listObjectsV2(
        bucket: pkgBucket.name ?? "pritt-packages",
        prefix: path,
      );

      final file = list.contents?.firstWhere((e) => e.key == path);
      return file == null
          ? null
          : CRSFile(
              path: path,
              lastModified: file.lastModified,
              size: file.size ?? 0,
            );
    } on StateError catch (e) {
      throw CRSException(
        CRSExceptionType.PACKAGE_NOT_FOUND,
        "The archive at the given path could not be found",
        e,
      );
    } on NoSuchKey catch (e) {
      throw CRSException(
        CRSExceptionType.PACKAGE_NOT_FOUND,
        "The archive at the given path could not be found",
        e,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CRSFile>> listAllPackages() async {
    final list = await s3Instance.listObjectsV2(
      bucket: pkgBucket.name ?? "pritt-packages",
    );

    return list.contents
            ?.map(
              (e) => CRSFile(
                path: e.key!,
                lastModified: e.lastModified,
                size: e.size ?? 0,
              ),
            )
            .toList() ??
        [];
  }

  @override
  Future<List<CRSFile>> listPackagesWhere(
    bool Function(String path) where,
  ) async {
    final list = await s3Instance.listObjectsV2(
      bucket: pkgBucket.name ?? "pritt-packages",
    );

    return list.contents
            ?.where((e) => where(e.key ?? ''))
            .map(
              (e) => CRSFile(
                path: e.key!,
                lastModified: e.lastModified,
                size: e.size ?? 0,
              ),
            )
            .toList() ??
        [];
  }

  @override
  FutureOr removePackage(String path) async {
    // remove the object from the bucket
    await s3Instance.deleteObject(
      bucket: pkgBucket.name ?? "pritt-packages",
      key: path,
    );
  }

  @override
  FutureOr updatePackage(String path, Uint8List data) async {
    try {
      final original = await s3Instance.getObject(
        bucket: pkgBucket.name ?? "pritt-packages",
        key: path,
      );

      await s3Instance.putObject(
        bucket: pkgBucket.name ?? "pritt-packages",
        key: path,
        body: data,
        contentType: original.contentType,
        metadata: original.metadata,
      );
    } on NoSuchKey catch (e) {
      throw CRSException(
        CRSExceptionType.PACKAGE_NOT_FOUND,
        "The archive at the given path could not be found",
        e,
      );
    } catch (e) {
      throw CRSException(CRSExceptionType.ITEM_NOT_FOUND, e.toString(), e);
    }
  }

  @override
  Future<CRSFileOutputStream> getPackage(String path) async {
    // get the object from the bucket
    final object = await s3Instance.getObject(
      bucket: pkgBucket.name ?? "pritt-packages",
      key: path,
    );

    if (object.body == null) {
      throw CRSException(
        CRSExceptionType.OBJECT_NOT_FOUND,
        'Could not find archive at $path',
      );
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
  FutureOr<bool> createPubArchive(
    String path,
    Uint8List data, {
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    // Create the object in the bucket
    try {
      await s3Instance.putObject(
        bucket: publishingBucket.name ?? 'pritt-publishing-archives',
        key: path,
        body: data,
        // contentLength: ,
        contentType: contentType,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  FutureOr<CRSFileOutputStream> getPubArchive(String path) async {
    final object = await s3Instance.getObject(
      bucket: publishingBucket.name ?? 'pritt-publishing-archives',
      key: path,
    );

    if (object.body == null) {
      throw CRSException(
        CRSExceptionType.OBJECT_NOT_FOUND,
        'Could not find archive at $path',
      );
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
  FutureOr movePubArchiveToPackage(String from, String to) async {
    // Get the object from the bucket
    final object = await s3Instance.getObject(
      bucket: publishingBucket.name ?? 'pritt-publishing-archives',
      key: from,
    );

    // Create the object in the bucket
    await s3Instance.putObject(
      bucket: pkgBucket.name ?? "pritt-packages",
      key: to,
      body: object.body,
      contentType: object.contentType,
      metadata: object.metadata,
    );
  }

  @override
  FutureOr<bool> pubArchiveExists(String path) async {
    try {
      final pkgStatus = await s3Instance.headObject(
        bucket: publishingBucket.name ?? 'pritt-publishing-archives',
        key: path,
      );

      return pkgStatus.metadata != null;
    } catch (e) {
      return false;
    }
  }

  @override
  FutureOr removePubArchive(String path) async {
    await s3Instance.deleteObject(
      bucket: publishingBucket.name ?? 'pritt-publishing-archives',
      key: path,
    );
  }

  @override
  FutureOr<Uri> createPubEndpointUrl(String path, {required String pubId}) {
    // TODO: implement createPubEndpointUrl
    throw UnimplementedError();
  }
}
