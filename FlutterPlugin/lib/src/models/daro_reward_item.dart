class DaroRewardItem {
  final int amount;
  final String type;

  DaroRewardItem({
    required this.amount,
    required this.type,
  });

  factory DaroRewardItem.fromMap(Map<String, dynamic> map) {
    return DaroRewardItem(
      amount: map['amount'] as int? ?? 0,
      type: map['type'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'DaroRewardItem(amount: $amount, type: $type)';
  }
}
