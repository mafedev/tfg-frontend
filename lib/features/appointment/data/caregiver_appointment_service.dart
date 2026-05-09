import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/shared/enums/appointment/appointment_status.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_request.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';

class AppointmentService {
  static const String _baseUrl = ApiConfig.appointmentEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Crear cita --------------------
  Future<void> createAppointment(AppointmentRequest request) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // indica que el cuerpo de la petición es JSON
      },
      body: jsonEncode(request.toJson()), // convierte los objetos Dart en JSON para enviarlos
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando cita',
    );
  }

  // -------------------- Obtener citas --------------------
  Future<List<AppointmentResponse>> getAppointmentsByPatient(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/patient/$patientId';

    // Petición
    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    // valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo citas',
    );

    final List data = jsonDecode(response.body);

    // convierte la respuesta JSON en una lista de objetos AppointmentResponse
    return data.map((e) => AppointmentResponse.fromJson(e)).toList();
  }

  // -------------------- Borrar cita --------------------
  Future<void> deleteAppointment(int id) async {
    final token = await _secureStorageService.getToken();

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$id';

    // Petición
    final response = await http.delete(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error eliminando cita',
    );
  }

  // -------------------- Editar cita --------------------
  Future<void> updateAppointment({
    required int id,
    required AppointmentRequest request,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$id';

    // Petición
    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // indica que el cuerpo es JSON
      },
      body: jsonEncode(request.toJson()), // convierte el request en un JSON para enviarlo
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando cita',
    );
  }

  // -------------------- Cambiar estado --------------------
  Future<void> updateStatus({
    required int id,
    required AppointmentStatus status,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$id/status?status=${status.name}';

    // Petición
    final response = await http.patch(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token"},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error actualizando estado de la cita',
    );
  }
}
