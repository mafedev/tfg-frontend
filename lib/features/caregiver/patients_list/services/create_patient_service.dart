import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class PatientService {
  final String baseUrl = ApiConfig.patientsEndpoint;

  Future<void> createPatientWithoutUser(
    String name,
    String phone,
    String diseaseStage,
    String notes,
  ) async {
    final token = await SecureStorageService().getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'phone': phone,
        'diseaseStage': diseaseStage,
        'notes': notes,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error: ${response.statusCode}');
    }
  }
}
