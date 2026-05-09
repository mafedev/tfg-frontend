import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/shared/enums/user/patient/disease_stage.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class PatientService {
  final String baseUrl = ApiConfig.patientsEndpoint;

  // ------------- Crear paciente sin usuario -------------
  Future<void> createPatientWithoutUser(
    String name,
    String phone,
    DiseaseStage diseaseStage,
    String notes,
  ) async {
    final token = await SecureStorageService().getToken(); // obtiene el token

    // Petición
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
      body: json.encode({ // convierte los objetos Dart a JSON para enviarlo
        'name': name,
        'phone': phone,
        'diseaseStage': diseaseStage.name,
        'notes': notes,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
