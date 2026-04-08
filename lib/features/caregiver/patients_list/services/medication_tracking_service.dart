import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class MedicationTrackingService {
  static const String _baseUrl = ApiConfig.patientsEndpoint;
  static const String _trackingUrl = ApiConfig.medicationTrackingEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Obtener tracking por fecha --------------------
  // obtiene el seguimiento de un paciente en una fecha específica
  Future<List<Map<String, dynamic>>> getMedicationTracking(int patientId, DateTime date) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // formatea la fecha a yyyy-MM-dd para  pasarla como parámetro en la URL
    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // hace la petición
    final response = await http.get(
      Uri.parse('$_baseUrl/$patientId/tracking?date=$formattedDate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // si sale bien
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body); // decodifica la respuesta JSON a una lista
      return data.cast<Map<String, dynamic>>(); // el cast pasa la lista a una lista clave:valor para poder usarla más fácilmente en la interfaz
    } else {
      throw Exception('Error GET tracking: ${response.statusCode}'); // si hay un error lo muestra
    }
  }

  // -------------------- Toggle --------------------
  Future<void> toggleTracking(int prescriptionId, String scheduledTime) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // hace la petición
    final response = await http.put(
      Uri.parse(
        '$_trackingUrl/toggle?prescriptionId=$prescriptionId&scheduledTime=$scheduledTime',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error PUT tracking: ${response.statusCode}');
    }
  }
}