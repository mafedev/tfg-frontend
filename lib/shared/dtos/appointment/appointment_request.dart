class AppointmentRequest {
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final int patientId;

  AppointmentRequest({
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.patientId,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "location": location,
      "dateTime": dateTime.toIso8601String(),
      "patientId": patientId,
    };
  }
}
