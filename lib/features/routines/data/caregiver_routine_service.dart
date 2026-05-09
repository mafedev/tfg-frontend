import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class RoutineService {
  final String _routineUrl = ApiConfig.routineEndpoint;
  final String _itemsUrl = "${ApiConfig.routineEndpoint}/items";
  final String _trackingUrl = "${ApiConfig.routineEndpoint}/tracking";

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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
    );
    final data = jsonDecode(response.body); // convierte los objetos a JSON para enviarlo

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error creando rutina");
    }

    return data['id'];
  }


  // ---------------- Crear item ----------------
  Future<void> createItem({
    required int routineId,
    required String name,
    required String time,
    required String type,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
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
    final token = await _secureStorageService.getToken(); // obtiene el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
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

  // ---------- Tracking ----------
  Future<List<Map<String, dynamic>>> getTracking({required int patientId, required DateTime date}) async {
    final token = await _secureStorageService.getToken(); // obtiene el token
    final formattedDate = date.toIso8601String().split('T')[0];

    // Petición
    final response = await http.get(
      Uri.parse('$_trackingUrl/$patientId?date=$formattedDate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  // ---------- Cambiar estado rutina ----------
  Future<void> updateTrackingStatus({
    required int trackingId,
    required String status,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // Petición
    final response = await http.put(
      Uri.parse('$_trackingUrl/$trackingId?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error actualizando tracking');
    }
  }

  // ---------- Editar rutina ----------
  Future<void> updateRoutine(
    int routineId,
    List<Map<String, dynamic>> items,
  ) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // Petición
    final response = await http.put(
      Uri.parse('$_routineUrl/$routineId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"items": items}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error actualizando rutina");
    }
  }

  // ---------- Editar item de rutina ----------
  Future<void> updateItem({
    required int itemId,
    required String name,
    required String time,
    required String type,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // Petición
    final response = await http.put(
      Uri.parse('$_itemsUrl/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"name": name, "time": time, "type": type}),
    );

    if (response.statusCode != 200) {
      throw Exception("Error actualizando item");
    }
  }
  
  // ---------- Borrar rutina ----------
  Future<void> deleteRoutine(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // Petición
    final response = await http.delete(
      Uri.parse('$_routineUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Error eliminando rutina");
    }
  }

  // ---------- Borrar item de rutina ----------
  Future<void> deleteItem(int itemId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // Petición
    final response = await http.delete(
      Uri.parse('$_itemsUrl/$itemId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Error eliminando item");
    }
  }
}
