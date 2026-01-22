import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/secure_storage_service.dart';

class RoutineService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';
  final SecureStorageService _secureStorageService = SecureStorageService();

 // ------------- Crear rutina -------------
 // Crea una nueva rutina para un paciente
  Future<void> createRoutine({
    required int patientId,
    required String breakfastTime,
    required String lunchTime,
    required String dinnerTime,
    required String bathTime,
    required bool enableHydration,
    required int waterReminder
  }) async {
    // Obtener el token del almacenamiento seguro
    String? token = await _secureStorageService.getToken();
    
    if (token == null) {
      throw Exception('Token no disponible. Por favor inicia sesión.');
    }

    // hace la petición POST al backend
    final response = await http.post(
      Uri.parse('$_baseUrl/routine'), // Endpoint para crear rutina
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Agregar token de autenticación
      },
      // cuerpo de la petición con los datos de la rutina
      body: jsonEncode({
        'patientId': patientId,
        'breakfastTime': breakfastTime,
        'lunchTime': lunchTime,
        'dinnerTime': dinnerTime,
        'bathTime': bathTime,
        'enableHydration': enableHydration,
        'waterReminder': waterReminder,
      }),
    );

    // Si la respuesta no es 200, lanza una excepción
    if (response.statusCode != 200) {
      log('Error response status: ${response.statusCode}');
      log('Error body: ${response.body}');
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
