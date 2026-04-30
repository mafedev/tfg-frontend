import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class PrescriptionTrackingService {
  static const String _baseUrl = ApiConfig.prescriptionTrackingEndpoint;

  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- GET tracking por fecha --------------------
  Future<List<Map<String, dynamic>>> getMedicationTracking(
    DateTime date,
  ) async {
    final token = await _secureStorageService.getToken();

    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final url = '$_baseUrl?date=$formattedDate';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('Error GET tracking: ${response.statusCode}');
  }

  // -------------------- TOGGLE tracking --------------------
  Future<void> toggleTracking({
    required int prescriptionId,
    required String scheduledTime,
  }) async {
    final token = await _secureStorageService.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'prescriptionId': prescriptionId,
        'scheduledTime': scheduledTime,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error PUT tracking: ${response.statusCode}');
    }
  }
}
