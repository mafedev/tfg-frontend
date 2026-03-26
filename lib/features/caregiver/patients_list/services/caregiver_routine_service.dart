import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

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
    required bool hydrationEnabled,
    required int hydrationReminderHours
  }) async {
    // Obtener el token del almacenamiento seguro
    final token = await _secureStorageService.getToken();
    if (token == null) {
      throw Exception('Token no disponible. Por favor inicia sesión.');
    }

    // hace la petición POST al backend
    final response = await http.post(
      Uri.parse('$_baseUrl/routine/$patientId'), // Endpoint para crear rutina
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'breakfastTime': breakfastTime,
        'lunchTime': lunchTime,
        'dinnerTime': dinnerTime,
        'bathTime': bathTime,
        'hydrationEnabled': hydrationEnabled,
        'hydrationReminderHours': hydrationReminderHours,
      }),
    );

    if (response.statusCode != 200) {
      log('Error creando rutina: ${response.statusCode}');
      throw Exception('Error al crear rutina');
    }
  }

  // ---------- Obtener rutina ----------
  Future<Map<String, dynamic>?> getRoutine(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/routine/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 404) {
      return null; // no hay rutina
    }

    throw Exception('Error al obtener rutina');
  }

  // ---------- Editar rutina ----------
  Future<void> updateRoutine({
    required int patientId,
    required String breakfastTime,
    required String lunchTime,
    required String dinnerTime,
    required String bathTime,
    required bool hydrationEnabled,
    required int hydrationReminderHours,
  }) async {
    final token = await _secureStorageService.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/routine/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Agregar token de autenticación
      },
      // cuerpo de la petición con los datos de la rutina
      body: jsonEncode({
        'breakfastTime': breakfastTime,
        'lunchTime': lunchTime,
        'dinnerTime': dinnerTime,
        'bathTime': bathTime,
        'hydrationEnabled': hydrationEnabled,
        'hydrationReminderHours': hydrationReminderHours,
      }),
    );

    // Si la respuesta no es 200, lanza una excepción
    if (response.statusCode != 200) {
      log('Error response status: ${response.statusCode}');
      log('Error body: ${response.body}');
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  // ------------- Eliminar rutina -------------
  Future<void> deleteRoutine(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.delete(
      Uri.parse('$_baseUrl/routine/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      log('Error response status: ${response.statusCode}');
      log('Error body: ${response.body}');
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  // ---------- Marcar acción (desayuno, comida, cena, baño, hidratación) ----------
  Future<void> markAction(int trackingId, String action) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('$_baseUrl/routine-tracking/$trackingId/$action');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      log('Error al marcar $action: ${response.statusCode} - ${response.body}');
      throw Exception('Error al marcar $action');
    }
  }

  // ---------- Obtener tracking de hoy ----------
  Future<Map<String, dynamic>> getTodayTracking(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.get(
      Uri.parse('$_baseUrl/routine-tracking/today/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener tracking: ${response.statusCode}');
    }
  }

  // Marcar desayuno
  Future<void> markBreakfast(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final url = Uri.parse('$_baseUrl/routine-tracking/$patientId/breakfast');
    final res = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Error al marcar desayuno: ${res.statusCode}');
    }
  }
}
