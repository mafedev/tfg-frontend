import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/secure_storage_service.dart';

class RelationService {
  final String baseUrl = 'http://10.0.2.2:8080/api/relations';
  final SecureStorageService _storage = SecureStorageService();

  // Botón de generar
  Future<String?> generateRelationCode() async {
    final token = await _storage.getToken();

    if(token == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data['relationCode']; 
    } else {
      return null;
    }
  }
}