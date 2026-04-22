class RoiEntry {
  RoiEntry({
    required this.id,
    required this.portfolioId,
    required this.month,
    required this.year,
    required this.roiAmount,
    required this.roiPercentage,
    required this.paymentStatus,
    this.paymentDate,
  });

  final int id;
  final int portfolioId;
  final int month;
  final int year;
  final double roiAmount;
  final double roiPercentage;
  final String paymentStatus;
  final String? paymentDate;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory RoiEntry.fromJson(Map<String, dynamic> json) {
    return RoiEntry(
      id: _toInt(json['id']),
      portfolioId: _toInt(json['portfolio_id']),
      month: _toInt(json['month']),
      year: _toInt(json['year']),
      roiAmount: _toDouble(json['roi_amount']),
      roiPercentage: _toDouble(json['roi_percentage']),
      paymentStatus: (json['payment_status'] ?? 'Pending') as String,
      paymentDate: json['payment_date'] as String?,
    );
  }
}
