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

  factory ClientNotificationItem.fromJson(Map<String, dynamic> json) {
    return ClientNotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
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
