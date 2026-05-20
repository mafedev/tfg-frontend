import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';

class CaregiverHomeService {
  static String get _baseUrl => '${ApiConfig.caregiverHomeEndpoint}/prescriptions';
  static String get _calendarUrl => '${ApiConfig.caregiverHomeEndpoint}/calendar';

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

  Future<List<DateTime>> getCalendarDays() async {
    final token = await _secureStorageService.getToken();

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse(_calendarUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error cargando calendario',
    );

    final List<dynamic> data = json.decode(response.body);

    return data.map((e) => DateTime.parse(e['date'])).toList();
  }

  Future<List<dynamic>> getAppointmentsByDate(DateTime date) async {
    final token = await _secureStorageService.getToken();

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final formattedDate =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.caregiverHomeEndpoint}/calendar/details?date=$formattedDate",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error cargando citas del día',
    );

    return json.decode(response.body);
  }
}
