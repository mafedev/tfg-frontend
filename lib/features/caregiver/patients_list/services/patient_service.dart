import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/models/patient.dart';

class PatientService {
  final String baseUrl = 'http://10.0.2.2:8080/api'; // url base
  final SecureStorageService _storage =
      SecureStorageService(); // es para obtener el token guardado

  // ------------------- Obtener los detalles por paciente -------------------
  Future<Patient?> getPatientDetails(int patientId) async {
    // recibe el id del paciente para poder hacer la petición
    final token = await _storage.getToken(); // se obtiene el token desde el secure storage
    
    if (token == null) throw Exception('Token no disponible'); // si no hay token, se lanza una excepción

    final response = await http.get(
      Uri.parse('$baseUrl/patients/$patientId'),
      headers: {
        'Authorization': 'Bearer $token', // envía el token
        'Content-Type': 'application/json', // indica que está enviando un JSON
      },
    );

    // si todo salió bien
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body); // decodifica la respuesta JSON
      return Patient.fromJson(data); // convierte el JSON a un objeto Patient usando el método fromJson que se definió en el modelo Patient
    }
    return null; // si la respuesta no es 200, devuelve null
  }

  // ------------------- Actualizar los datos del paciente -------------------
  Future<void> updatePatient(Patient patient) async {
    final token = await _storage.getToken();

    // Si no hay token, se lanza una excepción
    // esto es importante porque sin el token no se puede autenticar la petición
    if (token == null) throw Exception('Token no disponible');

    // Hace la petición PUT para actualizar los datos del paciente
    await http.put(
      Uri.parse('$baseUrl/patients/${patient.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(patient.toJson()), // convierte el objeto Patient a JSON usando el método toJson que se definió en el modelo Patient
    );
  }
}
