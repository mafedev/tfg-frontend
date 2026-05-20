import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';

class ProfileService {
  static String get _baseUrl => ApiConfig.usersEndpoint;

  final SecureStorageService _secureStorageService = SecureStorageService();

  // -------------------- Obtener datos --------------------
  Future<Map<String, dynamic>> getMyProfile() async {
    final token = await _secureStorageService.getToken();

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error cargando perfil',
    );

    return jsonDecode(response.body);
  }

  // -------------------- Editar datos --------------------
  Future<void> updateMyProfile({
    required String username,
    required String email,
    required String phone,
  }) async {
    final token = await _secureStorageService.getToken();

    if (token == null) {
      throw Exception('Token no disponible');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'username': username, 'email': email, 'phone': phone}),
    );

    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error actualizando perfil',
    );
  }
}
