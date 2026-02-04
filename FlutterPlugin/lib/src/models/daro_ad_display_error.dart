class DaroAdDisplayError {
  final int code;
  final String message;

  DaroAdDisplayError({
    required this.code,
    required this.message,
  });

  factory DaroAdDisplayError.fromMap(Map<dynamic, dynamic> map) {
    return DaroAdDisplayError(
      code: map['code'] as int,
      message: map['message'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
    };
  }
}
