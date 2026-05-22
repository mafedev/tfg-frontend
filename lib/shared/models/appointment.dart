class Appointment {
  final int id;
  final String title;
  final String description;
  final String location;
  final String dateTime;
  final String status;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      dateTime: json['dateTime'],
      status: json['status'],
    );
  }
}
