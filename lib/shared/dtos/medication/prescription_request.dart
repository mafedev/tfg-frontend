import 'package:tfg_frontend/shared/enums/medication/prescription_status.dart';

class PrescriptionRequest {
  final int patientId;
  final int medicationId;
  final double dose;
  final DoseUnit doseUnit;
  final int? frequencyHours;
  final String? startDate;
  final String? endDate;
  final String? firstDoseTime;
  final String? notes;
  final String? status;

  PrescriptionRequest({
    required this.patientId,
    required this.medicationId,
    required this.dose,
    required this.doseUnit,
    this.frequencyHours,
    this.startDate,
    this.endDate,
    this.firstDoseTime,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "patientId": patientId,
      "medicationId": medicationId,
      "dose": dose,
      "doseUnit": doseUnit.name,
      "frequencyHours": frequencyHours,
      "startDate": startDate,
      "endDate": endDate,
      "firstDoseTime": firstDoseTime,
      "notes": notes,
      "status": status ?? "ACTIVE",
    };
  }
}