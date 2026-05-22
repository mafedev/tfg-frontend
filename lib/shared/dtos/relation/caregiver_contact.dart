class CaregiverContact {
  final int id;
  final String username;
  final String phone;

  CaregiverContact({
    required this.id,
    required this.username,
    required this.phone,
  });

  factory CaregiverContact.fromJson(Map<String, dynamic> json) {
    return CaregiverContact(
      id: json['id'],
      username: json['username'],
      phone: json['phone'],
    );
  }
}