import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class AppointmentService {
  static const String _baseUrl = ApiConfig.appointmentEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<bool> createAppointment({
    required String title,
    required String description,
    required String location,
    required String dateTime,
    required int patientId,
  }) async {
    final token = await _secureStorageService.getToken();

    final body = {
      "title": title,
      "description": description,
      "location": location,
      "dateTime": dateTime,
      "patientId": patientId,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR EXCEPTION: $e");
      return false;
    }
  }

  Future<List<dynamic>> getAppointmentsByPatient(int patientId) async {
    final token = await _secureStorageService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.appointmentEndpoint}/patient/$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error ${response.statusCode}");
    }
  }

  // borrar
  Future<void> deleteAppointment(int id) async {
    final token = await _secureStorageService.getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.appointmentEndpoint}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error eliminando cita");
    }
  }

  Future<bool> updateAppointment({
    required int id,
    required String title,
    required String description,
    required String location,
    required String dateTime,
  }) async {
    final token = await SecureStorageService().getToken();

    final response = await http.put(
      
      Uri.parse('${ApiConfig.appointmentEndpoint}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "location": location,
        "dateTime": dateTime,
      }),
    );

    return response.statusCode == 200;
  }

  Future<void> updateStatus(int id, String status) async {
    final response = await http.patch(
      Uri.parse(
        'http://10.0.2.2:8080/api/appointments/$id/status?status=$status',
      ),
      headers: {
        'Authorization': 'Bearer ${await SecureStorageService().getToken()}',
      },
    );

    print("UPDATE STATUS -> ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception("Error actualizando estado");
    }
  }
}
