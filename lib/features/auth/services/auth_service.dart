import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/enums/user_role.dart';
import 'package:tfg_frontend/models/user/login_response.dart';

// Responsabilidad: autenticación
class AuthService {
  final String baseUrl = ApiConfig.authEndpoint;

  // ------------------- Crear un nuevo usuario -------------------
  // Future es para que Flutter no se congele al hacer la petición, y todos lo datos son requeridos
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/signup');

    // Valida que ninguno de los datos este vacío
    if (username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      log('Signup validation failed: missing fields');
      return false; // si algo falta devuelve false
    }

    try {
      // envia los datos con POST para crear al usuario, await es para esperar la repsuesta
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // indica que está enviando un JSON
        body: jsonEncode({ // pasa el Map a JSON
          'username': username,
          'email': email,
          'password': password,
          'role': role.name,
          'phone': phone,
        }),
      );

    // compara la respuesta, si coincide devuelve true, sino false, y significa que hubo un error
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('Signup error: $e');
      return false;
    }
  }

  // ------------------- Iniciar sesión -------------------
  // Autentica el usuario, devuelve un Map con el token, el usuario, si falla devuelve un null
  Future<LoginResponse?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'}, // indica que envia un JSON
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        log('Login failed: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);

      return LoginResponse.fromJson(data);
    } catch (e) {
      log('Login error: $e');
      return null;
    }
  }
}
