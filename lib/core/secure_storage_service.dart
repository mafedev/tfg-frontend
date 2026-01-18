import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Maneja el almacenamiento seguro de los datos en el dispositivo
class SecureStorageService {
  static const _jwtKey = 'jwt_token';

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
}
