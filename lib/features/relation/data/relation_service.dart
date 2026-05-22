import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/dtos/relation/caregiver_contact.dart';
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

  // ------------------- Obtener cuidadores vinculados -------------------
  Future<List<CaregiverContact>> getMyCaregivers() async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/my-caregivers';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo cuidadores vinculados',
    );

    final List data = HttpResponseHandler.decodeList(response);
    return data.map((e) => CaregiverContact.fromJson(e)).toList();
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

  Future<void> saveCaregiverPhones() async {
    try {
      final token = await _storage.getToken();

      // Valida que exista el token
      if (token == null) {
        throw Exception(
          'Token no disponible para obtener números de cuidadores',
        );
      }

      final url = '$_baseUrl/my-caregivers';
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: la petición tardó más de 10 segundos');
            },
          );

      // Valida la respuesta HTTP
      if (response.statusCode != 200) {
        throw Exception('Error obteniendo números de cuidadores: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      if (data is! List) {
        throw Exception('Formato de respuesta inválido: se esperaba List, se recibió ${data.runtimeType}');
      }

      // Filtra números válidos (no nulos ni vacíos)
      final phones = (data as List)
          .map((e) => e['phone']?.toString() ?? '')
          .where((phone) => phone.isNotEmpty)
          .toList();

      print('[DEBUG] Números de teléfono obtenidos: $phones');

      // Guarda en SecureStorageService (más robusto que SharedPreferences)
      await _storage.saveCaregiverPhones(phones);
    } catch (e) {
      rethrow; // Permite que el error sea manejado en el login
    }
  }
}
