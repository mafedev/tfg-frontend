import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // URL base del backend
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  // Endpoints
  static String get authEndpoint => '$baseUrl/auth';
  static String get patientsEndpoint => '$baseUrl/patients';
  static String get prescriptionsEndpoint => '$baseUrl/prescriptions';
  static String get relationsEndpoint => '$baseUrl/relations';
  static String get medicationsEndpoint => '$baseUrl/medications';
  static String get routineEndpoint => '$baseUrl/routine';
  static String get appointmentEndpoint => '$baseUrl/appointments';
  
  // Endpoints para tracking
  static String get prescriptionTrackingEndpoint => '$baseUrl/prescription-tracking';
  static String get routineTrackingEndpoint => '$baseUrl/routine-tracking';

  static String get patientAllergies => '$baseUrl/patients';
  static String get caregiverHomeEndpoint => '$baseUrl/caregiver/home';
}
