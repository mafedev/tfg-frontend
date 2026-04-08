import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import '../models/patient.dart';

class RelationService {
  final String baseUrl = ApiConfig.relationsEndpoint;
  final SecureStorageService _storage = SecureStorageService();

  // ------------------- Generar código -------------------
  Future<String?> generateRelationCode() async {
    final token = await _storage.getToken();

    if(token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['relationCode'];
    } else {
      return null;
    }
  }

  // ------------------- Vincular paciente -------------------
  Future<bool> linkPatient(String code) async {
    final token = await _storage.getToken();

    if (token == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/link'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    );

    return response.statusCode == 200;
  }

  // ------------------- Obtener pacientes -------------------
  Future<List<Patient>> getPatients() async {
    final token = await _storage.getToken();

    if (token == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Patient.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  // ------------------- Eliminar relación -------------------
  Future<bool> deleteRelation(int patientId) async {
    final token = await _storage.getToken();

    if (token == null) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}