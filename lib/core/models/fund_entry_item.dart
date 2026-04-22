class FundEntryItem {
  FundEntryItem({
    required this.id,
    required this.portfolioId,
    required this.fundType,
    required this.status,
    required this.amount,
    required this.pnlPercentage,
    this.portfolioNumber,
    this.stockName,
    this.entryDate,
    this.timestamp,
  });

  final int id;
  final int portfolioId;
  final String fundType;
  final String status;
  final double amount;
  final double pnlPercentage;
  final String? portfolioNumber;
  final String? stockName;
  final String? entryDate;
  final String? timestamp;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory FundEntryItem.fromJson(Map<String, dynamic> json) {
    return FundEntryItem(
      id: _toInt(json['id']),
      portfolioId: _toInt(json['portfolio_id']),
      fundType: (json['fund_type'] ?? 'Fund') as String,
      status: (json['status'] ?? 'Closed') as String,
      amount: _toDouble(json['amount']),
      pnlPercentage: _toDouble(json['pnl_percentage']),
      portfolioNumber: json['portfolio_number'] as String?,
      stockName: json['stock_name'] as String?,
      entryDate: json['entry_date'] as String?,
      timestamp: json['timestamp'] as String?,
    );
  }
}
