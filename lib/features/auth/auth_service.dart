// Clase para manejar la autenticación del usuario, lo que hace es comunicarse con el backend y enviar las solicitudes de inicio de sesión y registro
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8080/api/auth';

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    // Validación local básica antes de enviar
    if (username.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty || phone.isEmpty) {
      print('Signup local validation failed: missing fields');
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
          'phone': phone
        }),
      );

      print('SIGNUP ${response.statusCode} ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      return null;
    }
  }
}