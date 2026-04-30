import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/enums/medication_type.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/models/medication/medication_response.dart';

class CaregiverMedicationService {
  static const String _baseUrl = ApiConfig.medicationsEndpoint;
  final SecureStorageService _secureStorageService = SecureStorageService();

  // ------------- Crear medicamento -------------
  Future<void> createMedication(
    String name,
    String description,
    MedicationType type,
  ) async {
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
        // enviamos el nombre del enum para que el backend reciba un string válido
        'type': type.name,
      }),
    );

    // si la respuesta no es 200, lanza una excepción con el código de estado
    if (response.statusCode != 200) {
      throw Exception('Error al crear medicamento: ${response.statusCode} - ${response.body}');
    }
  }

  // ---------- Obtener medicamentos ----------
  Future<List<MedicationResponse>> getMedications() async {
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

    final List data = jsonDecode(response.body);

    return data.map((e) => MedicationResponse.fromJson(e)).toList();
  }
}
