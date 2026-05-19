import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/enums/medication/medication_type.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/dtos/medication/medication_response.dart';

class CaregiverMedicationService {
  static String get _baseUrl => ApiConfig.medicationsEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // ------------- Crear medicamento -------------
  Future<void> createMedication(
    String name,
    String description,
    MedicationType type,
  ) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es JSON
      },
      body: jsonEncode({ // convierte los objetos Dart en JSON
        'name': name,
        'description': description,
        // enviamos el nombre del enum para que el backend reciba un string válido
        'type': type.name,
      }),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error al crear medicamento',
    );
  }

  // ---------- Obtener medicamentos ----------
  Future<List<MedicationResponse>> getMedications() async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error al obtener medicamentos',
    );

    final List data = jsonDecode(response.body);

    return data.map((e) => MedicationResponse.fromJson(e)).toList();
  }
}
