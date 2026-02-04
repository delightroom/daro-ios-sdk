class DaroAdInfo {
  final String adUnitId;
  final String? format;

  DaroAdInfo({
    required this.adUnitId,
    this.format,
  });

  factory DaroAdInfo.fromMap(Map<dynamic, dynamic> map) {
    return DaroAdInfo(
      adUnitId: map['adUnitId'] as String,
      format: map['format'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adUnitId': adUnitId,
      if (format != null) 'format': format,
    };
  }
}
