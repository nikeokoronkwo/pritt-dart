import 'package:json_annotation/json_annotation.dart';

import '../../utils/mixins.dart';

part 'error.g.dart';

@JsonSerializable()
class SwiftError with JsonConvertible {
  final String detail;
  final String? title;
  final int? status;

  const SwiftError({
    required this.detail,
    this.title,
    this.status
  });

  factory SwiftError.fromJson(Map<String, dynamic> json) 
    => _$SwiftErrorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SwiftErrorToJson(this);
}