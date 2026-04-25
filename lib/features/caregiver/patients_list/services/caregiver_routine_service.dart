import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class RoutineService {
  final String _routineUrl = ApiConfig.routineEndpoint;
  final String _itemsUrl = ApiConfig.routineEndpoint + "/items";
  final SecureStorageService _secureStorageService = SecureStorageService();

  // ------------- Crear rutina -------------
  // Crea una nueva rutina para un paciente
  Future<int> createRoutine(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.post(
      Uri.parse('$_routineUrl/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);

      if (data == null || data['id'] == null) {
        throw Exception("Respuesta inválida del backend");
      }

      return data['id'];
    }

    throw Exception('Error creando rutina: ${response.body}');
  }

  // ---------------- Crear item ----------------
  Future<void> createItem({
    required int routineId,
    required String name,
    required String time,
    required String type,
  }) async {
    // Obtener el token del almacenamiento seguro
    final token = await _secureStorageService.getToken();
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // hace la petición POST al backend
    final response = await http.post(
      Uri.parse('$_itemsUrl/$routineId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"name": name, "time": time, "type": type}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error creando item: ${response.body}');
    }
  }

  // ---------- Obtener rutina ----------
  Future<Map<String, dynamic>?> getRoutine(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse('$_routineUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 404) {
      return null; // no hay rutina
    }

    throw Exception('Error obteniendo rutina: ${response.body}');
  }
}
