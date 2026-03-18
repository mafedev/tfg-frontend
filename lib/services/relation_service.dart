import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import '../models/patient.dart';

class RelationService {
  final String baseUrl = 'http://10.0.2.2:8080/api/relations';
  final SecureStorageService _storage = SecureStorageService();

  // ------------------- Botón de generar ------------------- 
  Future<String?> generateRelationCode() async {
    final token = await _storage.getToken();

    if(token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['relationCode'];
    } else {
      return null;
    }
  }

  // ------------------- Enlaza al paciente con el cuidador ------------------- 
  Future<String?> linkPatient(String code) async {
    final token = await _storage.getToken();

    if(token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/link'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['relationCode'];
    } else {
      return null;
    }
  }

  // ------------------- Obtiene la lista de pacientes por cuidador ------------------- 
  Future<List<Patient>> getPatients() async {
    final token = await _storage.getToken();

    if (token == null) {
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Patient.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  // ------------------- Elimina la relación entre cuidador y paciente ------------------- 
  Future<bool> deleteRelation(int patientId) async {
    final token = await _storage.getToken();

    if (token == null) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}
