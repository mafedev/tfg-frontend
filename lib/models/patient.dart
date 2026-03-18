class Patient {
  final int id;
  final String username;
  final String? phone;
  final String? notes;
  final String? diseaseStage; 

// Constructor
  Patient({
    required this.id,
    required this.username,
    required this.phone,
    this.notes,
    this.diseaseStage,
  });

// Crea el paciente a partir del JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'], // obtiene el id del json
      username: json['username'], // obtiene el nombre del JSON
      phone: json['phone'], // puede ser null
      notes: json['notes'], 
      diseaseStage: json['diseaseStage'], 
    );
  }
}
