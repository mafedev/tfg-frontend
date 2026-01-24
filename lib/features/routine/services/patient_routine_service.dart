import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tfg_frontend/features/routine/models/routine.dart';

class PatientRoutineService {
  final String baseUrl = 'http://10.0.2.2:8080/api';

  // ----------- Obtiene la rutina del paciente -----------
  Future<Routine?> getMyRoutine(String token) async {
    // Hace la petición y pasa el token
    final response = await http.get(
      Uri.parse(
        '$baseUrl/routine',
      ), // Endpotin para obtener la rutina del paciente
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
