class ClientProfile {
  ClientProfile({
    required this.id,
    required this.clientCode,
    required this.name,
    required this.email,
    this.phone,
    this.alternatePhone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.panNumber,
    this.nomineeName,
    this.kycStatus,
    this.isBlocked = false,
    this.dateOfBirth,
  });

  final int id;
  final String clientCode;
  final String name;
  final String email;
  final String? phone;
  final String? alternatePhone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? panNumber;
  final String? nomineeName;
  final String? kycStatus;
  final bool isBlocked;
  final String? dateOfBirth;

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: _toInt(json['id']),
      clientCode: (json['client_code'] ?? '—') as String,
      name: (json['name'] ?? 'Client') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone'] as String?,
      alternatePhone: json['alternate_phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode']?.toString(),
      panNumber: json['pan_number'] as String?,
      nomineeName: json['nominee_name'] as String?,
      kycStatus: json['kyc_status'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      dateOfBirth: json['date_of_birth'] as String?,
    );
  }
}
