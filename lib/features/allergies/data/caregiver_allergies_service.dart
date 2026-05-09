import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/enums/allergies/allergies_severity.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class AllergyService {
  static const String _baseUrl = ApiConfig.patientAllergies;
  final SecureStorageService _storage = SecureStorageService(); // instancia del servicio de almacenamiento seguro

  // -------------------- Crear alergia --------------------
  Future<void> create({
    required int patientId,
    required String name,
    required String description,
    required AllergySeverity severity,
  }) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId/allergies';

    // Petición
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que envía un JSON
      },
      // convierte los objetos Dart en JSON
      body: jsonEncode({
        'name': name,
        'description': description,
        'severity': severity.name,
      }),
    );

    // valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando alergia',
    );
  }

  // -------------------- Obtener alergias por paciente --------------------
  // Devuelve una lista de objetos JSON -> String:valor 
  Future<List<Map<String, dynamic>>> getByPatient(int patientId) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId/allergies';

    // Petición
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo alergias',
    );

    // convierte la respuesta JSON en una lista de mapas
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  // -------------------- Eliminar alergia --------------------
  Future<void> delete({required int patientId, required int allergyId}) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId/allergies/$allergyId';

    // Petición
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error eliminando alergia',
    );
  }

  // -------------------- Editar severidad --------------------
  Future<void> updateSeverity({
    required int patientId,
    required int allergyId,
    required AllergySeverity severity,
  }) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId/allergies/$allergyId';

    // Petición
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que envía un JSON
      },
      body: jsonEncode({'severity': severity.name}), // envia solo la severidad actualizada en formato JSON
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando severidad',
    );
  }
}
