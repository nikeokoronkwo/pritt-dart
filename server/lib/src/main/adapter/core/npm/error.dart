import '../../adapter_base.dart';

class NpmError with MetaResult {
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
