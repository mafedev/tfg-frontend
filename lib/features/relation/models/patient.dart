class Patient {
  final int id;
  final String username;

  Patient({
    required this.id,
    required this.username,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      username: json['username'],
    );
  }
}