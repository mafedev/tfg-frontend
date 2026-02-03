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
}
