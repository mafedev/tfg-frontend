import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/models/medication_tracking.dart';

class PatientMedicationService {
  static const String _baseUrl = ApiConfig.prescriptionTrackingEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // Obtiene el tracking de medicamentos del paciente para una fecha específica
  Future<List<MedicationTracking>> getMedicationTrackingForDate(DateTime date) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Hace la petición para obtener el tracking
    final response = await http.get(
      Uri.parse('$_baseUrl?date=$formattedDate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // si sale bien, parsea la respuesta y devuelve la lista de tracking
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => MedicationTracking.fromJson(json)).toList();
    }

    throw Exception('Error GET tracking: ${response.statusCode}');
  }
}
