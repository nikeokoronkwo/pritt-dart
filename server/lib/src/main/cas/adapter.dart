import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server/src/main/adapter/adapter/result.dart';
import 'package:pritt_server/src/main/utils/mixins.dart';

part 'adapter.g.dart';

@JsonEnum()
enum CustomAdapterResultType {
  meta,
  archive;

  static CustomAdapterResultType fromString(String s) =>
      CustomAdapterResultType.values.firstWhere((f) => f.name == s);
}

@JsonSerializable(createFactory: false)
sealed class CustomAdapterResult extends AdapterBaseResult implements Jsonable {
  @JsonKey(name: 'result_type')
  final CustomAdapterResultType resultType;

  CustomAdapterResult({required this.resultType});

  AdapterResult toAdapterResult();

  factory CustomAdapterResult.fromJson(Map<String, dynamic> json) {
    return switch (CustomAdapterResultType.fromString(json['result_type'])) {
      // TODO: Handle this case.
      CustomAdapterResultType.meta => throw UnimplementedError(),
      // TODO: Handle this case.
      CustomAdapterResultType.archive => throw UnimplementedError(),
    };
  }

}

// TODO: Implement
class CustomAdapterMetaResult extends CustomAdapterResult
    implements AdapterMetaResult {

  CustomAdapterMetaResult({required super.resultType});

  @override
  // TODO: implement responseType
  ResponseType get responseType => throw UnimplementedError();

  @override
  // TODO: implement body
  JsonConvertible get body => throw UnimplementedError();

  @override
  AdapterResult toAdapterResult() {
    // TODO: implement toAdapterResult
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

// TODO: Implement
class CustomAdapterArchiveResult extends CustomAdapterResult
    implements AdapterMetaResult {
  CustomAdapterArchiveResult({required super.resultType});

  @override
  // TODO: implement responseType
  ResponseType get responseType => throw UnimplementedError();

  @override
  // TODO: implement body
  JsonConvertible get body => throw UnimplementedError();

  @override
  AdapterResult toAdapterResult() {
    // TODO: implement toAdapterResult
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
