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
}
