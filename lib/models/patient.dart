import 'package:tfg_frontend/core/enums/disease_stage.dart';

class Patient {
  final int id;
  final String? username;
  final String? name;
  final String? phone;
  final String? notes;
  final DiseaseStage? diseaseStage;

  Patient({
    required this.id,
    this.username,
    this.name,
    this.phone,
    this.notes,
    this.diseaseStage,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      phone: json['phone'],
      notes: json['notes'],
      diseaseStage: json['diseaseStage'] != null
          ? DiseaseStage.values.firstWhere(
              (e) => e.name == json['diseaseStage'],
              orElse: () => DiseaseStage.EARLY,
            )
          : null,
    );
  }
}