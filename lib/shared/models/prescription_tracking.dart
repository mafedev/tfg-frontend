class PrescriptionTrackingTime {
  final String scheduledTime;
  final String status;

  PrescriptionTrackingTime({required this.scheduledTime, required this.status});

  factory PrescriptionTrackingTime.fromJson(Map<String, dynamic> json) {
    return PrescriptionTrackingTime(
      scheduledTime: json['scheduledTime'],
      status: json['status'],
    );
  }

  bool get isTaken => status == 'TAKEN';
}

class PrescriptionTracking {
  final int prescriptionId;
  final String medicationName;
  final String dose;
  List<PrescriptionTrackingTime> times;

  PrescriptionTracking({
    required this.prescriptionId,
    required this.medicationName,
    required this.dose,
    required this.times,
  });

  factory PrescriptionTracking.fromJson(Map<String, dynamic> json) {
    final timesJson = json['times'] as List<dynamic>? ?? [];

    return PrescriptionTracking(
      prescriptionId: json['prescriptionId'],
      medicationName: json['medicationName'] ?? '',
      dose: json['dose'] ?? '',
      times: timesJson
          .map((t) => PrescriptionTrackingTime.fromJson(t))
          .toList(),
    );
  }
}
