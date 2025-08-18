import 'package:json_annotation/json_annotation.dart';
import '../../adapter/resolve.dart';

part 'sorter.g.dart';

class SorterResponse {
  final bool success;
  final String workerId;

  const SorterResponse({
    required this.success,
    required this.workerId,
  });

  factory SorterResponse.fromJson(Map<String, dynamic> json) =>
    json['success'] ? _$SorterSuccessResponseFromJson(json) : _$SorterFailureResponseFromJson(json);

  Map<String, dynamic> toJson() => success
    ? _$SorterSuccessResponseToJson(this as SorterSuccessResponse)
    : _$SorterFailureResponseToJson(this as SorterFailureResponse);
}

@JsonSerializable()
class SorterSuccessResponse extends SorterResponse {
  // TODO: Add in pritt_runner id
  final String adapterId;
  @JsonKey(name: 'result')
  final AdapterResolveType type;

  @override
  bool get success => true;

  const SorterSuccessResponse({
    required this.type,
    required super.workerId,
    required this.adapterId
  }) : super(success: true);

  factory SorterSuccessResponse.fromJson(Map<String, dynamic> json) =>
    _$SorterSuccessResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SorterSuccessResponseToJson(this);
}

@JsonSerializable()
class SorterFailureResponse extends SorterResponse {
  @override
  bool get success => false;

  const SorterFailureResponse({
    required super.workerId,
  }) : super(success: false);

  factory SorterFailureResponse.fromJson(Map<String, dynamic> json) =>
    _$SorterFailureResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SorterFailureResponseToJson(this);
}