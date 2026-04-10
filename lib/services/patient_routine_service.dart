import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfg_frontend/core/config/api_config.dart';
import 'package:tfg_frontend/models/routine.dart';

class PatientRoutineService {
  final String baseUrl = ApiConfig.routineEndpoint;

  // ----------- Obtiene la rutina del paciente -----------
  Future<Routine?> getMyRoutine(String token) async {
    // Hace la petición y pasa el token
    final response = await http.get(
      Uri.parse(baseUrl), // Endpotin para obtener la rutina del paciente
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) { // si todo sale bien
      return Routine.fromJson(jsonDecode(response.body)); // crea y devuelve un objeto Routine a partir del JSON recibido
    } else {
      return null;
    }
  }
}
