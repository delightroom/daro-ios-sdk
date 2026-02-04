class AdEventData {
  final String eventType;
  final String adUnitId;
  final Map<String, dynamic> event;

  AdEventData._({
    required this.eventType,
    required this.adUnitId,
    required this.event,
  });

  static AdEventData? parse(dynamic rawEvent) {
    if (rawEvent is! Map) return null;

    final eventType = rawEvent['eventType'] as String?;
    final adUnitId = rawEvent['adUnitId'] as String?;

    if (eventType == null || adUnitId == null) return null;

    return AdEventData._(
      eventType: eventType,
      adUnitId: adUnitId,
      event: Map<String, dynamic>.from(rawEvent),
    );
  }
}
