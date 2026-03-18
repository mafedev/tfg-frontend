class Patient {
  final int id;
  final String name;
  final String? phone;
  final String? notes;
  final String? diseaseStage;
  final int? userId;

  // Constructor
  Patient({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.diseaseStage,
    this.userId,
  });

  // Crea el paciente a partir del JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'] ?? json['username'], // soporta ambos casos
      phone: json['phone'],
      notes: json['notes'],
      diseaseStage: json['diseaseStage'],
      userId: json['user'] != null ? json['user']['id'] : null,
    );
  }

  // Convierte el paciente a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'notes': notes,
      'diseaseStage': diseaseStage,
    };
  }
}
