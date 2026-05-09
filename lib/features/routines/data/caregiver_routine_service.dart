import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/models/routine.dart';

class RoutineService {
  static const String _baseUrl = ApiConfig.routineEndpoint;
  static const String _itemsUrl = '$_baseUrl/items';
  static const String _trackingUrl = '$_baseUrl/tracking';

  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Crear rutina --------------------
  // Crea una nueva rutina para un paciente
  Future<int> createRoutine(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token
    
    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.post(
      Uri.parse('$_baseUrl/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando rutina',
    );

    final data = jsonDecode(response.body); // convierte la respuesta en JSON
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

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.post(
      Uri.parse('$_itemsUrl/$routineId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"name": name, "time": time, "type": type}),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando item',
    );
  }

  // ---------- Obtener rutina ----------
  Future<Map<String, dynamic>?> getRoutine(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.get(
      Uri.parse('$_baseUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo rutina',
    );

    return jsonDecode(response.body);
  }

  // ---------- Tracking ----------
  Future<List<Map<String, dynamic>>> getTracking({
    required int patientId,
    required DateTime date,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final formattedDate = date.toIso8601String().split('T')[0];
    
    // Petición
    final response = await http.get(
      Uri.parse('$_trackingUrl/$patientId?date=$formattedDate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo tracking',
    );

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  // ---------- Cambiar estado rutina ----------
  Future<void> updateTrackingStatus({
    required int trackingId,
    required String status,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.put(
      Uri.parse('$_trackingUrl/$trackingId?status=$status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando tracking',
    );
  }

  // ---------- Editar rutina ----------
  Future<void> updateRoutine(
    int routineId,
    List<Map<String, dynamic>> items,
  ) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.put(
      Uri.parse('$_baseUrl/$routineId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"items": items}),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando rutina',
    );
  }

  // ---------- Editar item de rutina ----------
  Future<void> updateItem({
    required int itemId,
    required String name,
    required String time,
    required String type,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.put(
      Uri.parse('$_itemsUrl/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"name": name, "time": time, "type": type}),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando item',
    );
  }

  // ---------- Borrar rutina ----------
  Future<void> deleteRoutine(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }
    
    // Petición
    final response = await http.delete(
      Uri.parse('$_baseUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error eliminando rutina',
    );
  }

  // ---------- Borrar item de rutina ----------
  Future<void> deleteItem(int itemId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.delete(
      Uri.parse('$_itemsUrl/$itemId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error eliminando item',
    );
  }

  // PATIENT
  // ---------- Obtener mi rutina ----------
  Future<Routine?> getMyRoutine() async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo mi rutina',
    );

    return Routine.fromJson(jsonDecode(response.body));
  }
}
