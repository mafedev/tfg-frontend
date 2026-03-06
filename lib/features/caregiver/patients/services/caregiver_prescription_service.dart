import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/enums/prescription.dart';
import 'package:tfg_frontend/core/secure_storage_service.dart';

class CaregiverPrescriptionService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/prescriptions';

  final SecureStorageService _secureStorageService = SecureStorageService();

  // ---------- Crear prescripción ----------
  Future<void> createPrescription({
    required int patientId,
    required int medicationId,
    required double dose,
    required DoseUnit doseUnit,
    int? frequencyHours,
    String? startDate,
    String? endDate,
    String? firstDoseTime,
    List<int>? daysOfWeek,
    String? notes,
    String? status,
  }) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final body = {
      'patientId': patientId,
      'medicationId': medicationId,
      'dose': dose,
      'doseUnit': doseUnit.name,
      'frequencyHours': frequencyHours,
      'startDate': startDate,
      'endDate': endDate,
      'firstDoseTime': firstDoseTime,
      'daysOfWeek': daysOfWeek != null ? _daysToApi(daysOfWeek) : null,
      'notes': notes,
      'status': status ?? 'ACTIVE',
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
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
    required int patientId,
    required int medicationId,
    required double dose,
    required DoseUnit doseUnit,
    int? frequencyHours,
    String? startDate,
    String? endDate,
    String? firstDoseTime,
    List<int>? daysOfWeek,
    String? notes,
    String? status,
  }) async {
    final token = await _secureStorageService.getToken();
    if (token == null) throw Exception('Token no disponible');

    final body = {
      'patientId': patientId,
      'medicationId': medicationId,
      'dose': dose,
      'doseUnit': doseUnit.name,
      'frequencyHours': frequencyHours,
      'startDate': startDate,
      'endDate': endDate,
      'firstDoseTime': firstDoseTime,
      'daysOfWeek': daysOfWeek != null ? _daysToApi(daysOfWeek) : null,
      'notes': notes,
      'status': status ?? 'ACTIVE',
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/$prescriptionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar prescripción: ${response.body}');
    }
  }

  // ---------- Convertir días a formato API ----------
  List<String> _daysToApi(List<int> days) {
    return days.map((d) {
      switch (d) {
        case 1:
          return 'MONDAY';
        case 2:
          return 'TUESDAY';
        case 3:
          return 'WEDNESDAY';
        case 4:
          return 'THURSDAY';
        case 5:
          return 'FRIDAY';
        case 6:
          return 'SATURDAY';
        case 7:
          return 'SUNDAY';
        default:
          throw Exception('Día inválido');
      }
    }).toList();
  }
}