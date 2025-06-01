import 'package:json_annotation/json_annotation.dart';
import 'package:pritt_common/interface.dart';

part 'poll.g.dart';

@JsonSerializable()
class AuthPollSuccessResponse extends AuthPollResponse {
  String id;
  @JsonKey(name: 'access_token')
  String accessToken;

  AuthPollSuccessResponse(
      {required super.status,
      super.response,
      required this.id,
      required this.accessToken});

  factory AuthPollSuccessResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthPollSuccessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthPollSuccessResponseToJson(this);
}
