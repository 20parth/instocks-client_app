class PortfolioItem {
  PortfolioItem({
    required this.id,
    required this.portfolioNumber,
    required this.portfolioType,
    required this.status,
    required this.initialInvestment,
    required this.currentCapital,
    required this.totalRoiPaid,
    required this.totalRoiUnpaid,
    this.groupCode,
    this.paymentDate,
    this.maturityDate,
    this.startDate,
    this.roiPercentage = 0,
  });

  final int id;
  final String portfolioNumber;
  final String portfolioType;
  final String status;
  final double initialInvestment;
  final double currentCapital;
  final double totalRoiPaid;
  final double totalRoiUnpaid;
  final String? groupCode;
  final String? paymentDate;
  final String? maturityDate;
  final String? startDate;
  final double roiPercentage;

  double get totalRoi => totalRoiPaid + totalRoiUnpaid;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      portfolioNumber: (json['portfolio_number'] ?? '—') as String,
      portfolioType: (json['portfolio_type'] ?? 'Portfolio') as String,
      status: (json['status'] ?? 'Active') as String,
      initialInvestment: _toDouble(json['initial_investment']),
      currentCapital: _toDouble(json['current_capital']),
      totalRoiPaid: _toDouble(json['total_roi_paid']),
      totalRoiUnpaid: _toDouble(json['total_roi_unpaid']),
      groupCode: json['group_code'] as String?,
      paymentDate: json['payment_date']?.toString(),
      maturityDate: json['maturity_date'] as String?,
      startDate: json['start_date'] as String?,
      roiPercentage: _toDouble(json['roi_percentage']),
    );
  }
}
