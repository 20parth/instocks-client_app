class AuthUser {
  AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.clientId,
    this.clientCode,
    this.phone,
    this.kycStatus,
    this.isBlocked = false,
    this.createdAt,
    this.lastLogin,
  });

  final int id;
  final String fullName;
  final String email;
  final String role;
  final int? clientId;
  final String? clientCode;
  final String? phone;
  final String? kycStatus;
  final bool isBlocked;
  final String? createdAt;
  final String? lastLogin;

  bool get isClient => role.toLowerCase() == 'client';

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final client = json['client'] as Map<String, dynamic>?;

    return AuthUser(
      id: _toInt(json['id']),
      fullName: (json['full_name'] ??
          json['name'] ??
          json['username'] ??
          'Client') as String,
      email: (json['email'] ?? '') as String,
      role: (json['role'] ?? 'Client') as String,
      clientId: json['client_id'] != null
          ? _toInt(json['client_id'])
          : (client?['id'] != null ? _toInt(client!['id']) : null),
      clientCode: client?['client_code'] as String?,
      phone: client?['phone'] as String?,
      kycStatus: client?['kyc_status'] as String?,
      isBlocked: client?['is_blocked'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      lastLogin: json['last_login'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'client_id': clientId,
      'client': {
        'client_code': clientCode,
        'phone': phone,
        'kyc_status': kycStatus,
        'is_blocked': isBlocked,
      },
      'created_at': createdAt,
      'last_login': lastLogin,
    };
  }
}
