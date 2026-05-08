import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/shared/enums/appointment/appointment_status.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_request.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';

class AppointmentService {
  static const String _baseUrl = ApiConfig.appointmentEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<bool> createAppointment(AppointmentRequest request) async {
    final token = await _secureStorageService.getToken();

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  // -------------------- Obtener citas --------------------
  Future<List<AppointmentResponse>> getAppointmentsByPatient(
    int patientId,
  ) async {
    final token = await _secureStorageService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/patient/$patientId'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode}");
    }

    final List data = jsonDecode(response.body);

    return data.map((e) => AppointmentResponse.fromJson(e)).toList();
  }

  // borrar
  Future<void> deleteAppointment(int id) async {
    final token = await _secureStorageService.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 204) {
      throw Exception("Error eliminando cita");
    }
  }

  // -------------------- Editar cita --------------------
  Future<bool> updateAppointment({
    required int id,
    required AppointmentRequest request,
  }) async {
    final token = await _secureStorageService.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    return response.statusCode == 200;
  }

  // -------------------- Cambiar estado --------------------
  Future<bool> updateStatus({required int id, required AppointmentStatus status}) async {
    final token = await _secureStorageService.getToken();

    final response = await http.patch(
      Uri.parse('$_baseUrl/$id/status?status=${status.name}'),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 204;
  }
}
