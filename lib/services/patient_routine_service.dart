import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/models/routine.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class PatientRoutineService {
  final String baseUrl = 'http://10.0.2.2:8080/api';
  final SecureStorageService _storage = SecureStorageService();

  // ----------- Obtiene la rutina del paciente ----------- 
  Future<Routine?> getMyRoutine() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/routine'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) { // si todo sale bien
      return Routine.fromJson(jsonDecode(response.body)); // crea y devuelve un objeto Routine a partir del JSON recibido
    } else {
      return null;
    }
  }
}
