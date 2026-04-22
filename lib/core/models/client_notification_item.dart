class ClientNotificationItem {
  ClientNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    this.portfolioNumber,
    this.pushStatus,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final String notificationType;
  final bool isRead;
  final String? portfolioNumber;
  final String? pushStatus;
  final String? createdAt;

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory ClientNotificationItem.fromJson(Map<String, dynamic> json) {
    return ClientNotificationItem(
      id: _toInt(json['id']),
      title: (json['title'] ?? 'Notification') as String,
      message: (json['message'] ?? '') as String,
      notificationType: (json['notification_type'] ?? 'general') as String,
      isRead: json['is_read'] as bool? ?? false,
      portfolioNumber: json['portfolio_number'] as String?,
      pushStatus: json['push_status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
