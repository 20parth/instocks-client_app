class NotificationPreference {
  NotificationPreference({
    required this.id,
    required this.notificationType,
    required this.allowInApp,
    required this.allowEmail,
    required this.allowPush,
  });

  final int id;
  final String notificationType;
  final bool allowInApp;
  final bool allowEmail;
  final bool allowPush;

  NotificationPreference copyWith({
    bool? allowInApp,
    bool? allowEmail,
    bool? allowPush,
  }) {
    return NotificationPreference(
      id: id,
      notificationType: notificationType,
      allowInApp: allowInApp ?? this.allowInApp,
      allowEmail: allowEmail ?? this.allowEmail,
      allowPush: allowPush ?? this.allowPush,
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: _toInt(json['id']),
      notificationType: (json['notification_type'] ?? 'general') as String,
      allowInApp: json['allow_in_app'] as bool? ?? true,
      allowEmail: json['allow_email'] as bool? ?? true,
      allowPush: json['allow_push'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'notification_type': notificationType,
      'allow_in_app': allowInApp,
      'allow_email': allowEmail,
      'allow_push': allowPush,
    };
  }
}
