import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_server/src/main/adapter/adapter/resolve.dart';

part 'sorter.g.dart';

@JsonSerializable()
class SorterResponse {
  @JsonKey(name: 'result')
  final AdapterResolveType type;
  final String? adapterId;
  final bool success;
  final String workerId;

  const SorterResponse({
    required this.type,
    this.adapterId,
    required this.success,
    required this.workerId
  });

  factory SorterResponse.fromJson(Map<String, dynamic> json) =>
      _$SorterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SorterResponseToJson(this);
}