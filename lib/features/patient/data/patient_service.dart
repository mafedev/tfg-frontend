import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/models/patient.dart';

class PatientService {
  final String baseUrl = ApiConfig.patientsEndpoint;
  final SecureStorageService _storage =
      SecureStorageService(); // es para obtener el token guardado

  // ------------------- Obtener los detalles por paciente -------------------
  Future<Patient?> getPatientDetails(int patientId) async {
    // recibe el id del paciente para poder hacer la petición
    final token = await _storage
        .getToken(); // se obtiene el token desde el secure storage

    // hace la petición
    final response = await http.get(
      Uri.parse('$baseUrl/$patientId'),
      headers: {
        'Authorization': 'Bearer $token', // envía el token
        'Content-Type': 'application/json', // indica que está enviando un JSON
      },
    );

    if (response.statusCode == 200) {
      // si todo salió bien
      return Patient.fromJson(json.decode(response.body));
    } else {
      // sino devuelve null
      return null;
    }
  }

  // ------------------- Actualizar los datos del paciente -------------------
  Future<void> updatePatient(
    int patientId,
    String phone,
    String notes,
    String? diseaseStage,
  ) async {
    final token = await _storage.getToken();
    // Hace la petición PUT para actualizar los datos del paciente
    await http.put(
      Uri.parse('$baseUrl/$patientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'phone': phone,
        'notes': notes,
        'diseaseStage': diseaseStage,
      }),
    );
  }
}
