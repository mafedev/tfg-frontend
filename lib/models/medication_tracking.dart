class MedicationTrackingTime {
  final String scheduledTime;
  bool taken;
  final String status;

  MedicationTrackingTime({
    required this.scheduledTime,
    required this.taken,
    required this.status,
  });

  factory MedicationTrackingTime.fromJson(Map<String, dynamic> json) {
    return MedicationTrackingTime(
      scheduledTime: json['scheduledTime'] ?? '',
      taken: json['taken'] ?? false,
      status: json['status'] ?? 'PENDING',
    );
  }
}

class MedicationTracking {
  final int prescriptionId;
  final String medicationName;
  final String dose;
  final List<MedicationTrackingTime> times;

  MedicationTracking({
    required this.prescriptionId,
    required this.medicationName,
    required this.dose,
    required this.times,
  });

  factory MedicationTracking.fromJson(Map<String, dynamic> json) {
    final timesJson = json['times'] as List<dynamic>? ?? [];
    final times = timesJson
        .map((t) => MedicationTrackingTime.fromJson(t))
        .toList();
    return MedicationTracking(
      prescriptionId: json['prescriptionId'],
      medicationName: json['medicationName'] ?? '',
      dose: json['dose'] ?? '',
      times: times,
    );
  }
}
