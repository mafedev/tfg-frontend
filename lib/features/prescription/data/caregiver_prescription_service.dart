import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/dtos/medication/prescription_request.dart';

class CaregiverPrescriptionService {
  static const String _baseUrl = ApiConfig.prescriptionsEndpoint;

  final SecureStorageService _secureStorageService = SecureStorageService();

  // ---------- Crear prescripción ----------
  Future<void> createPrescription(PrescriptionRequest request) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al crear prescripción: ${response.body}');
    }
  }

  // ---------- Obtener prescripciones de un paciente ----------
  Future<List<dynamic>> getByPatient(int patientId) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.get(
      Uri.parse('$_baseUrl/patient/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error cargando prescripciones');
    }

    return jsonDecode(response.body);
  }

  // ---------- Eliminar prescripción ----------
  Future<void> deletePrescription(int id) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar prescripción');
    }
  }

  // ---------- Actualizar prescripción ----------
  Future<void> updatePrescription({
    required int prescriptionId,
    required PrescriptionRequest request,
  }) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final response = await http.put(
      Uri.parse('$_baseUrl/$prescriptionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar prescripción: ${response.body}');
    }
  }
}