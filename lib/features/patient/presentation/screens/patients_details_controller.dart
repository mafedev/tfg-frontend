import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/features/patient/data/patient_service.dart';
import 'package:tfg_frontend/features/prescription/data/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/models/patient.dart';

class PatientDetailsController {
  final PatientService _patientService = PatientService();
  final RoutineService _routineService = RoutineService();
  final AppointmentService _appointmentService = AppointmentService();
  final CaregiverPrescriptionService _prescriptionService =
      CaregiverPrescriptionService();

  // -------------------- Patient --------------------
  Future<Patient?> loadPatient(int patientId) async {
    return await _patientService.getPatientDetails(patientId);
  }

  Future<void> updatePatient({
    required int patientId,
    required String phone,
    required String notes,
    required String? diseaseStage,
  }) async {
    await _patientService.updatePatient(patientId, phone, notes, diseaseStage);
  }

  // -------------------- Routine --------------------
  Future<bool> hasRoutine(int patientId) async {
    final routine = await _routineService.getRoutine(patientId);
    return routine != null;
  }

  // -------------------- Medication --------------------
  Future<bool> hasMedication(int patientId) async {
    final meds = await _prescriptionService.getByPatient(patientId);

    final active = meds.where((m) {
      final status = m['status'] ?? 'ACTIVE';
      return status != 'CANCELLED';
    });

    return active.isNotEmpty;
  }

  // -------------------- Appointments --------------------
  Future<bool> hasAppointments(int patientId) async {
    final result = await _appointmentService.getAppointmentsByPatient(
      patientId,
    );

    return result.isNotEmpty;
  }
}
