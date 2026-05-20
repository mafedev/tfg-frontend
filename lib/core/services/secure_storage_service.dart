import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Maneja el almacenamiento seguro de los datos en el dispositivo
class SecureStorageService {
  static const _jwtKey = 'jwt_token';
  static const _usernameKey = 'username';

  // _storage es el que interactúa con el almacenamiento seguro
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Guarda el token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  // Recupera el token que se guardó
  Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  // Guarda el nombre de usuario
  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  // Recupera el nombre de usuario guardado
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Limpia todo logout
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
