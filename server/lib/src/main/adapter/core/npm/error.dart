import 'package:pritt_server/src/main/utils/mixins.dart';

class NpmError with JsonConvertible {
  final String? error;

  NpmError({this.error});

  factory NpmError.fromJson(Map<String, dynamic> json) {
    return NpmError(
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
