import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tfg_frontend/core/secure_storage_service.dart';

class PatientService {
  final String baseUrl = 'http://10.0.2.2:8080/api';
  final SecureStorageService _storage = SecureStorageService();

  // ------------------- Obtener los detalles por paciente -------------------
  Future<Map<String, dynamic>?> getPatientDetails(int patientId) async {
    final token = await _storage.getToken(); // se obtiene el token

    final response = await http.get(
      Uri.parse('$baseUrl/patients/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }
    );

    if(response.statusCode == 200){
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}