import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';

class CaregiverHomeService {
  static String get _baseUrl =>'${ApiConfig.caregiverHomeEndpoint}/prescriptions';

  final SecureStorageService _secureStorageService = SecureStorageService();

  // Obtiene las próximas tomas pendientes de hoy
  Future<List<dynamic>> getHomePrescriptions() async {
    final token = await _secureStorageService.getToken();

    // verifica token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // petición
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // valida respuesta
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error cargando próximas tomas',
    );

    // devuelve lista
    return json.decode(response.body);
  }
}
