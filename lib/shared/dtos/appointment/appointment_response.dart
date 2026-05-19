class AppointmentResponse {
  final int id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String status;

  AppointmentResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.status,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
    );
  }
}
