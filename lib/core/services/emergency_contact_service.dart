import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/dtos/relation/caregiver_contact.dart';

class EmergencyContactService {
  final SecureStorageService _storage = SecureStorageService();

  static String get _baseUrl => '${ApiConfig.baseUrl}/api/relations';

  Future<void> loadAndStoreCaregiverPhones() async {
    try {
      final token = await _storage.getToken();

      final response = await http.get(
        Uri.parse('$_baseUrl/my-caregivers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) return;

      final List data = jsonDecode(response.body);

      final caregivers = data.map((e) => CaregiverContact.fromJson(e)).toList();

      final phones = caregivers.map((c) => c.phone).toList();

      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList('caregiver_phones', phones);
    } catch (_) {}
  }

  Future<List<String>> getPhones() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('caregiver_phones') ?? [];
  }
}
