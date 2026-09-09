class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
    );
  }
}
