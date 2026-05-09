import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';

class PatientMedicationService {
  static const String _baseUrl = ApiConfig.prescriptionTrackingEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Obtener tracking de medicamentos --------------------
  // Obtiene el tracking de medicamentos del paciente para una fecha específica
  Future<List<PrescriptionTracking>> getMedicationTrackingForDate(DateTime date) async {
    final token = await _secureStorageService.getToken();

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final url = '$_baseUrl?date=$formattedDate';

    // Petición
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // valida respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo tracking de medicamentos',
    );

    // convierte la respuesta JSON en una lista de objetos PrescriptionTracking
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => PrescriptionTracking.fromJson(json)).toList();
  }
}
