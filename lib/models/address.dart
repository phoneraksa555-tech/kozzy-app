class Address {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final bool isDefault;

  Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    this.country = 'Cambodia',
    this.zipcode = '',
    this.isDefault = false,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get formatted => '$street, $city, $state, $country';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'isDefault': isDefault,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Cambodia',
      zipcode: json['zipcode']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }
}
