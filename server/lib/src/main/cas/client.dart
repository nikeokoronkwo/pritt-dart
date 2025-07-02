import 'package:json_annotation/json_annotation.dart';

import '../utils/mixins.dart';
import 'adapter.dart';

part 'client.g.dart';

@JsonEnum()
enum CASMessageType {
  crsRequest,
  crsResponse,
  metaRequest,
  metaResponse,
  archiveRequest,
  archiveResponse;

  static CASMessageType? fromString(String s) => switch (s) {
        'crsRequest' => CASMessageType.crsRequest,
        'crsResponse' => CASMessageType.crsResponse,
        'metaRequest' => CASMessageType.metaRequest,
        'metaResponse' => CASMessageType.metaResponse,
        'archiveRequest' => CASMessageType.archiveRequest,
        'archiveResponse' => CASMessageType.archiveResponse,
        _ => null
      };
}

@JsonSerializable()
class CASMessage {
  @JsonKey(name: 'message_type')
  final CASMessageType messageType;

  const CASMessage({
    required this.messageType,
  });

  factory CASMessage.fromJson(Map<String, dynamic> json) {
    return switch (CASMessageType.fromString(json['messageType'])) {
      CASMessageType.crsRequest => _$CASRequestFromJson(json),
      _ => _$CASMessageFromJson(json)
    };
  }

  Map<String, dynamic> toJson() => _$CASMessageToJson(this);
}

// @JsonSerializable()
// class CustomAdapterStartRequest extends CASMessage {

// }

/// Requests sent from CAS to the API in order to perform async function calls
@JsonSerializable(createToJson: false)
class CASRequest extends CASMessage {
  final String id;
  final String method;
  final Map<String, dynamic> params;

  const CASRequest(
      {required this.id, required this.method, required this.params})
      : super(messageType: CASMessageType.crsRequest);

  factory CASRequest.fromJson(Map<String, dynamic> json) =>
      _$CASRequestFromJson(json);
}

/// Responses sent from the API to CAS to return the result of async function calls
@JsonSerializable()
class CASResponse extends CASMessage {
  final String id;
  final Map<String, dynamic> data;
  final String? error;

  static Map<String, dynamic> tToJson<T extends Jsonable>(T data) =>
      data.toJson();

  const CASResponse({required this.id, required this.data, this.error})
      : super(messageType: CASMessageType.crsResponse);

  factory CASResponse.fromJson(Map<String, dynamic> json) =>
      _$CASResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CASResponseToJson(this);

  CASBuiltResponse<T> build<T extends Jsonable>(
          {required T Function(Map<String, dynamic>) convertData}) =>
      CASBuiltResponse(id: id, data: convertData(data), error: error);
}

@JsonSerializable(genericArgumentFactories: true)
class CASBuiltResponse<T extends Jsonable> extends CASMessage {
  final String id;
  @JsonKey(
    toJson: tToJson,
  )
  final T data;
  final String? error;

  static Map<String, dynamic> tToJson<T extends Jsonable>(T data) =>
      data.toJson();

  const CASBuiltResponse({required this.id, required this.data, this.error})
      : super(messageType: CASMessageType.crsResponse);

  factory CASBuiltResponse.fromJson(Map<String, dynamic> json,
          {required T Function(Object?) convert}) =>
      _$CASBuiltResponseFromJson(json, convert);

  @override
  Map<String, dynamic> toJson() =>
      _$CASBuiltResponseToJson(this, (t) => t.toJson());
}

/// Response sent from CAS to indicate completed adapter processing
@JsonSerializable(createFactory: false)
class CustomAdapterCompleteResponse<T extends CustomAdapterResult>
    extends CASBuiltResponse<T> {
  CustomAdapterCompleteResponse(
      {required super.id, required super.data, super.error});

  @override
  CASMessageType get messageType => switch (T) {
        CustomAdapterMetaResult() => CASMessageType.metaResponse,
        _ => throw Exception('Must either be meta or archive')
      };

  @override
  Map<String, dynamic> toJson() => _$CustomAdapterCompleteResponseToJson(this);
}
