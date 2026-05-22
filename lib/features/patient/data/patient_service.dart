import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/enums/user/patient/disease_stage.dart';
import 'package:tfg_frontend/shared/models/patient.dart';

class PatientService {
  static String get _baseUrl => ApiConfig.patientsEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // CAREGIVER
  // ------------- Crear paciente sin usuario -------------
  Future<void> createPatientWithoutUser(
    String name,
    String phone,
    DiseaseStage diseaseStage,
    String notes,
  ) async {
    final token = await _secureStorageService.getToken(); // obtiene el token

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // Petición
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
      body: json.encode({ // convierte los objetos Dart a JSON para enviarlo
        'name': name,
        'phone': phone,
        'diseaseStage': diseaseStage.name,
        'notes': notes,
      }),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error creando paciente',
    );
  }

  // COMPARTIDO
  // ------------------- Obtener los detalles por paciente -------------------
  Future<Patient?> getPatientDetails(int patientId) async {
    final token = await _secureStorageService.getToken();

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // indica que el cuerpo es un JSON
      },
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error obteniendo paciente',
    );

    return Patient.fromJson(jsonDecode(response.body)); // convierte el JSON de la respuesta a un objeto Patient
  }

  // COMPARTIDO
  // ------------------- Actualizar los datos del paciente -------------------
  Future<void> updatePatient(
    int patientId,
    String phone,
    String notes,
    String? diseaseStage,
  ) async {
    final token = await _secureStorageService.getToken();

    // verifica que exista el token
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final url = '$_baseUrl/$patientId';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({ // convierte los objetos Dart a JSON para enviarlo
        'phone': phone,
        'notes': notes,
        'diseaseStage': diseaseStage,
      }),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando paciente',
    );
  }
}