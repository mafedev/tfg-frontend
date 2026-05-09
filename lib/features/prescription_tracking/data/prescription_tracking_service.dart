import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';

class PrescriptionTrackingService {
  static const String _baseUrl = ApiConfig.prescriptionTrackingEndpoint;

  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Obtener tracking por fecha --------------------
  Future<List<PrescriptionTracking>> getMedicationTracking(
    DateTime date,
  ) async {
    final token = await _secureStorageService.getToken(); // obtiene el token
    
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

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo tracking',
    );

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((json) => PrescriptionTracking.fromJson(json)).toList();
  }

  // -------------------- TOGGLE tracking --------------------
  Future<void> toggleTracking({
    required int prescriptionId,
    required String scheduledTime,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token
    
    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/toggle';

    // Petición
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
      body: jsonEncode({ // convierte los objetos a JSON para enviarlos
        'prescriptionId': prescriptionId,
        'scheduledTime': scheduledTime,
      }),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando tracking',
    );
  }
}
