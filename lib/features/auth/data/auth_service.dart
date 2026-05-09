import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/shared/enums/user/user_role.dart';
import 'package:tfg_frontend/core/utils/http_response_handler.dart';
import 'package:tfg_frontend/shared/dtos/user/login_response.dart';

class AuthService {
  static const String _baseUrl = ApiConfig.authEndpoint;

  // ------------------- Crear un nuevo usuario -------------------
  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    required String phone,
  }) async {
    final url = '$_baseUrl/signup';
    // Valida que ninguno de los datos este vacío
    if (username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      throw Exception('Todos los campos son obligatorios');
    }

    // Petición
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, // indica que está enviando un JSON
      body: jsonEncode({ // cambia los objetos Dart a JSON para enviarlos
        'username': username,
        'email': email,
        'password': password,
        'role': role.name,
        'phone': phone,
      }),
    );

    // Valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200, 201],
      errorMessage: 'Error registrando usuario',
    );
  }

  // ------------------- Iniciar sesión -------------------
  // Autentica el usuario, devuelve un Map con el token, el usuario, si falla devuelve un null
  Future<LoginResponse> login(String email, String password) async {
    // valida que los datos no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son obligatorios');
    }

    final url = '$_baseUrl/login';

    // Petición
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, // indica que envia un JSON
      body: jsonEncode({'email': email, 'password': password}),
    );

    // valida la respuesta HTTP
    HttpResponseHandler.validate(
      response: response,
      expectedStatusCodes: [200],
      errorMessage: 'Error iniciando sesión',
    );

    final data = jsonDecode(response.body);

    return LoginResponse.fromJson(data);
  }
}
