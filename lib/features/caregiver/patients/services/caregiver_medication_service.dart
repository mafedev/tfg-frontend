import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/secure_storage_service.dart';

class CaregiverMedicationService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/medications';
  final SecureStorageService _secureStorageService = SecureStorageService();

  // ------------- Crear medicamento -------------
  Future<void> createMedication(String name, String description) async {
    final token = await _secureStorageService.getToken(); // se obtiene el token del secure storage

    // si el token es nulo, lanza una excepción
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // si está disponible, hace la petición POST al backend
    final response = await http.post(
      Uri.parse(_baseUrl), // Endpoint para crear medicamento
      headers: {
        'Content-Type': 'application/json', // indica que el cuerpo es JSON
        'Authorization': 'Bearer $token', // pasa el token en la cabecera
      },
      body: jsonEncode({ // convierte el cuerpo a JSON
        'name': name,
        'description': description,
      }),
    );

    // si la respuesta no es 200, lanza una excepción con el código de estado
    if (response.statusCode != 200) {
      throw Exception('Error al crear medicamento: ${response.statusCode} - ${response.body}');
    }
  }

  // ---------- Crear rutina de medicamentos ----------
  Future<void> createMedicationSchedule({
    required int patientId,
    required int medicationId,
    required int dose,
    String? startDate,
    String? endDate,
    int? frequencyHours,
    String? firstDoseTime,
    List<int>? daysOfWeek,
  }) async {
    final token = await _secureStorageService.getToken();
    
    // si el token es nulo, lanza una excepción
    if (token == null) {
      throw Exception('Token no disponible');
    }

    final body = {
      'patientId': patientId,
      'medicationId': medicationId,
      'dose': dose,
      'startDate': startDate,
      'endDate': endDate,
      'frequencyHours': frequencyHours,
      'firstDoseTime': firstDoseTime,
      'daysOfWeek': daysOfWeek,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/schedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body), // le pasa el body con los datos
    );

    // si hay algñun problema muestra el error
    if (response.statusCode != 200) {
      throw Exception('Error al crear rutina: ${response.body}');
    }
  }


  // ---------- Obtener medicamentos ----------
  Future<List<dynamic>> getMedications() async {
    final token = await _secureStorageService.getToken();
    
    // si el token es nulo, lanza una excepción
    if (token == null) {
      throw Exception('Token no disponible');
    }

    // si hay token, hace la petición
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // si algo sale mal muestra el error
    if (response.statusCode != 200) {
      throw Exception('Error al obtener medicamentos: ${response.body}');
    }

    return jsonDecode(response.body); // devuelve la lista de medicamentos
  }
}
