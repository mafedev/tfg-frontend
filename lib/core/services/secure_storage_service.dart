import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Maneja el almacenamiento seguro de los datos en el dispositivo
class SecureStorageService {
  static const _jwtKey = 'jwt_token';
  static const _usernameKey = 'username';
  static const _caregiverPhonesKey = 'caregiver_phones';

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

  // Guarda los números de teléfono de los cuidadores (separados por comas)
  Future<void> saveCaregiverPhones(List<String> phones) async {
    final phonesString = phones.join(',');
    await _storage.write(key: _caregiverPhonesKey, value: phonesString);
  }

  // Recupera los números de teléfono de los cuidadores
  Future<List<String>> getCaregiverPhones() async {
    final phonesString = await _storage.read(key: _caregiverPhonesKey);
    if (phonesString == null || phonesString.isEmpty) {
      return [];
    }
    return phonesString.split(',');
  }

  // Limpia todo logout
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
