import 'package:json_annotation/json_annotation.dart';

import '../adapter/base_result.dart';
import '../adapter/result.dart';
import '../utils/mixins.dart';

part 'adapter.g.dart';

@JsonEnum()
enum CustomAdapterResultType {
  meta,
  archive;

  static CustomAdapterResultType fromString(String s) =>
      CustomAdapterResultType.values.firstWhere((f) => f.name == s);
}

// TODO(nikeokoronkwo): Implement Interfaces, https://github.com/nikeokoronkwo/pritt-dart/issues/62
@JsonSerializable(createFactory: false)
sealed class CustomAdapterResult extends AdapterBaseResult implements Jsonable {
  @JsonKey(name: 'result_type')
  final CustomAdapterResultType resultType;

  CustomAdapterResult({required this.resultType});

  CoreAdapterResult toAdapterResult();

  factory CustomAdapterResult.fromJson(Map<String, dynamic> json) {
    return switch (CustomAdapterResultType.fromString(json['result_type'])) {
      CustomAdapterResultType.meta => throw UnimplementedError(),
      CustomAdapterResultType.archive => throw UnimplementedError(),
    };
  }

  @override
  Map<String, dynamic> toJson() => _$CustomAdapterResultToJson(this);
}

// TODO(nikeokoronkwo): Implement, https://github.com/nikeokoronkwo/pritt-dart/issues/62
class CustomAdapterMetaResult extends CustomAdapterResult
    implements CoreAdapterMetaResult {
  CustomAdapterMetaResult({required super.resultType});

  @override
  ResponseType get responseType => throw UnimplementedError();

  @override
  JsonConvertible get body => throw UnimplementedError();

  @override
  CoreAdapterResult toAdapterResult() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

// TODO(nikeokoronkwo): Implement, https://github.com/nikeokoronkwo/pritt-dart/issues/62
class CustomAdapterArchiveResult extends CustomAdapterResult
    implements CoreAdapterMetaResult {
  CustomAdapterArchiveResult({required super.resultType});

  @override
  ResponseType get responseType => throw UnimplementedError();

  @override
  JsonConvertible get body => throw UnimplementedError();

  @override
  CoreAdapterResult toAdapterResult() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}
