import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import '../../../shared/models/patient.dart';

class RelationService {
  final String _baseUrl = ApiConfig.relationsEndpoint;
  final SecureStorageService _storage = SecureStorageService();

  // ------------------- Generar código -------------------
  Future<String?> generateRelationCode() async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error generando código de relación',
    );

    final data = HttpResponseHandler.decode(response);
    return data['relationCode'];
  }

  // ------------------- Vincular paciente -------------------
  Future<void> linkPatient(String code) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.post(
      Uri.parse('$_baseUrl/link?code=$code'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error vinculando paciente',
    );
  }

  // ------------------- Obtener pacientes -------------------
  Future<List<Patient>> getPatients() async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.get(
      Uri.parse('$_baseUrl/patients'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo pacientes',
    );

    final List data = HttpResponseHandler.decodeList(response);
    return data.map((e) => Patient.fromJson(e)).toList();
  }

  // ------------------- Eliminar relación -------------------
  Future<void> deleteRelation(int patientId) async {
    final token = await _storage.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.delete(
      Uri.parse('$_baseUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 204],
      errorMessage: 'Error eliminando relación',
    );
  }
}
