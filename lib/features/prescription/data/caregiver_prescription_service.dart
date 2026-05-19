import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/dtos/medication/prescription_request.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';

class CaregiverPrescriptionService {
  static const String _baseUrl = ApiConfig.prescriptionsEndpoint;

  final SecureStorageService _secureStorageService = SecureStorageService();

  // ---------- Crear prescripción ----------
  Future<void> createPrescription(PrescriptionRequest request) async {
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
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
      body: jsonEncode(request.toJson()), // convierte el objeto a JSON
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando prescripción',
    );
  }

  // ---------- Obtener prescripciones de un paciente ----------
  Future<List<dynamic>> getByPatient(int patientId) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/patient/$patientId';

    // Petición
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error cargando prescripciones',
    );

    return jsonDecode(response.body); // devuelve la lista de prescripciones como una lista de mapas
  }

  // ---------- Eliminar prescripción ----------
  Future<void> deletePrescription(int id) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$id';

    // Petición
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [204],
      errorMessage: 'Error eliminando prescripción',
    );
  }

  // ---------- Actualizar prescripción ----------
  Future<void> updatePrescription({
    required int prescriptionId,
    required PrescriptionRequest request,
  }) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$prescriptionId';

    // Petición
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
      body: jsonEncode(request.toJson()), // convierte el objeto a JSON
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando prescripción',
    );
  }
}
