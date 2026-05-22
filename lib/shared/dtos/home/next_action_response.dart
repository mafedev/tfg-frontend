class NextActionResponse {
  final String type;
  final String title;
  final String scheduledTime;
  final int referenceId;
  final String patientName;

  NextActionResponse({
    required this.type,
    required this.title,
    required this.scheduledTime,
    required this.referenceId,
    required this.patientName,
  });

  factory NextActionResponse.fromJson(Map<String, dynamic> json) {
    return NextActionResponse(
      type: json['type'],
      title: json['title'],
      scheduledTime: json['scheduledTime'],
      referenceId: json['referenceId'],
      patientName: json['patientName'],
    );
  }
}
