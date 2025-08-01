import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server_core/pritt_server_core.dart';

class Uint8ListConverter implements JsonConverter<Uint8List?, List<int>?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(List<int>? json) {
    return json != null ? Uint8List.fromList(json) : null;
  }

  @override
  List<int>? toJson(Uint8List? object) {
    return object;
  }
}

class PackageVersionsConverter
    implements JsonConverter<PackageVersions, Map<String, dynamic>> {
  const PackageVersionsConverter();

  static const omittedFields = [
    'readme',
    'info',
    'hash',
    'signatures',
    'integrity',
  ];

  @override
  PackageVersions fromJson(Map<String, dynamic> json) {
    throw UnsupportedError('Converter does not support deserialization');
  }

  @override
  Map<String, dynamic> toJson(PackageVersions object) {
    return object.toJson().map((k, v) {
      if (k == 'package') {
        return MapEntry(k, v['name']);
      } else if (omittedFields.contains(k)) {
        return MapEntry(k, null);
      }
      return MapEntry(k, v);
    })..removeWhere((k, v) => v == null);
  }
}

class PackageVersionsMapConverter
    implements
        JsonConverter<Map<String, PackageVersions>, Map<String, dynamic>> {
  const PackageVersionsMapConverter();

  @override
  Map<String, PackageVersions> fromJson(Map<String, dynamic> json) {
    throw UnsupportedError('Converter does not support deserialization');
  }

  @override
  Map<String, dynamic> toJson(Map<String, PackageVersions> object) {
    return object.map((k, v) {
      return MapEntry(k, const PackageVersionsConverter().toJson(v));
    });
  }
}
