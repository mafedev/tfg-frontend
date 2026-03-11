import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/models/patient.dart';

class PatientService {
  final String baseUrl = 'http://10.0.2.2:8080/api'; // url base
  final SecureStorageService _storage =
      SecureStorageService(); // es para obtener el token guardado

  // ------------------- Obtener los detalles por paciente -------------------
  Future<Patient?> getPatientDetails(int patientId) async {
    // recibe el id del paciente para poder hacer la petición
    final token = await _storage
        .getToken(); // se obtiene el token desde el secure storage

    // hace la petición
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$patientId'),
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
  Future<bool> updatePatient({
    required int id,
    String? phone,
    String? notes,
    String? diseaseStage,
  }) async {
    final token = await SecureStorageService().getToken();

    // Hace la petición PUT para actualizar los datos del paciente
    final response = await http.put(
      Uri.parse('$baseUrl/patients/$id'),
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

    return response.statusCode == 200;
  }
}
