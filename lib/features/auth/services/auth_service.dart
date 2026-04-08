// Clase para manejar la autenticación del usuario, lo que hace es comunicarse con el backend y enviar las solicitudes de inicio de sesión y registro
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';

// Responsabilidad: autenticación
class AuthService {
  // url base de las peticiones de autenticación
  final String baseUrl = ApiConfig.authEndpoint;

  // ------------------- Crear un nuevo usuario -------------------
  // Future es para que Flutter no se congele al hacer la petición, y todos lo datos son requeridos
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/signup'); // une la url base con el endpoint encargado de registrar el usaurio

    // Valida que ninguno de los datos este vacío
    if (username.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty || phone.isEmpty) {
      log('Signup local validation failed: missing fields');
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
          'role': role,
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
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login'); // endpoint para el login

    // envia los datos para comprobarlos
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'}, // indica que envia un JSON
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) { // si todo salió bien
      final data = jsonDecode(response.body); // guarda los datos del json
      return data; // devuelve los datos
    } else {
      return null; // si algo falla, entonces devuelve null
    }
  }
}
