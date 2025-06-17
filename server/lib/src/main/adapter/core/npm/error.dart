import '../../../utils/mixins.dart';

class NpmError with JsonConvertible {
  final String? error;

  NpmError({this.error});

  factory NpmError.fromJson(Map<String, dynamic> json) {
    return NpmError(
      error: json['error'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'error': error,
    };
  }
}
