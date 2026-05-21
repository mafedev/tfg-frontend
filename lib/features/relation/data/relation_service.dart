import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> saveCaregiverPhones() async {
    try {
      print('[DEBUG] Iniciando saveCaregiverPhones...');
      
      final token = await _storage.getToken();
      print('[DEBUG] Token obtenido: ${token != null ? 'Sí' : 'NO'}');

      // Valida que exista el token
      if (token == null) {
        throw Exception('Token no disponible para obtener números de cuidadores');
      }

      final url = '$_baseUrl/my-caregivers';
      print('[DEBUG] URL: $url');
      print('[DEBUG] Base URL: $_baseUrl');

      print('[DEBUG] Realizando petición GET...');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: la petición tardó más de 10 segundos');
        },
      );

      print('[DEBUG] Respuesta recibida. Status code: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      // Valida la respuesta HTTP
      if (response.statusCode != 200) {
        throw Exception('Error obteniendo números de cuidadores: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      print('[DEBUG] Datos decodificados: $data');

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
      
      print('[DEBUG] Números guardados en SecureStorageService correctamente');
    } catch (e) {
      // Log del error para debugging
      print('[ERROR] Error guardando números de cuidadores: $e');
      print('[ERROR] Stack trace: ${StackTrace.current}');
      rethrow; // Permite que el error sea manejado en el login
    }
  }
}
