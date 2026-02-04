class DaroAdLoadError {
  final int code;
  final String message;
  final String? adUnitId;

  DaroAdLoadError({
    required this.code,
    required this.message,
    this.adUnitId,
  });

  factory DaroAdLoadError.fromMap(Map<dynamic, dynamic> map) {
    return DaroAdLoadError(
      code: map['code'] as int,
      message: map['message'] as String,
      adUnitId: map['adUnitId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'adUnitId': adUnitId,
    };
  }
}
