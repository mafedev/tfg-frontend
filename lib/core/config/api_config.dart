class ApiConfig {
  // URL base del backend
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // Endpoints
  static const String authEndpoint = '$baseUrl/auth';
  static const String patientsEndpoint = '$baseUrl/patients';
  static const String prescriptionsEndpoint = '$baseUrl/prescriptions';
  static const String relationsEndpoint = '$baseUrl/relations';
  static const String medicationsEndpoint = '$baseUrl/medications';
  static const String routineEndpoint = '$baseUrl/routine';
  
  // Endpoints para tracking
  static const String medicationTrackingEndpoint = '$patientsEndpoint/tracking';
  static const String routineTrackingEndpoint = '$baseUrl/routine-tracking';
}
