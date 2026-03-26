class Patient {
  final int id;
  final String? username;
  final String? name;
  final String? phone;
  final String? notes;
  final String? diseaseStage;

  // Constructor
  Patient({
    required this.id,
    this.username,
    this.name,
    this.phone,
    this.notes,
    this.diseaseStage,
  });

  // Crea el paciente a partir del JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      phone: json['phone'],
      notes: json['notes'],
      diseaseStage: json['diseaseStage'],
    );
  }
}
