import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/models/routine.dart';

class PatientRoutineService {
  final String baseUrl = ApiConfig.routineEndpoint;
  final SecureStorageService _storage = SecureStorageService();

  // ----------- Obtiene la rutina del paciente -----------
  Future<Routine?> getMyRoutine([String? token]) async {
    final t = token ?? await _storage.getToken();

    if (t == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $t'},
    );

    if (response.statusCode == 200) { // si todo sale bien
      return Routine.fromJson(jsonDecode(response.body)); // crea y devuelve un objeto Routine a partir del JSON recibido
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception('Error: ${response.statusCode}');
  }
}
