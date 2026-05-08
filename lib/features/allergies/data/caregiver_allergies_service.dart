import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/shared/enums/allergies/allergies_severity.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';

class AllergyService {
  final SecureStorageService _storage = SecureStorageService();

  Future<List<Map<String, dynamic>>> getByPatient(int patientId) async {
    final token = await _storage.getToken();
    final url = '${ApiConfig.patientAllergies}/$patientId/allergies';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    }

    throw Exception('Error cargando alergias');
  }

  Future<void> create({
    required int patientId,
    required String name,
    required String description,
    required AllergySeverity severity,
  }) async {
    final token = await _storage.getToken();
    final url = '${ApiConfig.patientAllergies}/$patientId/allergies';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'severity': severity.name,
      }),
    );
  }

  Future<void> delete({required int patientId, required int allergyId}) async {
    final token = await _storage.getToken();

    final url = '${ApiConfig.patientAllergies}/$patientId/allergies/$allergyId';

    final response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error eliminando alergia: ${response.statusCode}');
    }
  }

  Future<void> updateSeverity({
    required int patientId,
    required int allergyId,
    required AllergySeverity severity,
  }) async {
    final token = await _storage.getToken();

    final url = '${ApiConfig.patientAllergies}/$patientId/allergies/$allergyId';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'severity': severity.name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error actualizando severidad');
    }
  }
}
