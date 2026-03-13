import 'package:flutter/material.dart';
import 'package:tfg_frontend/models/patient.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/view_patient_routine.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/create_prescription_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/view_prescription_screen.dart';

class PatientActionButtons extends StatelessWidget {
  final Patient patient;
  final bool loadingRoutine;
  final bool hasRoutine;
  final bool loadingMedication;
  final bool hasMedication;
  final VoidCallback onEdit;

  const PatientActionButtons({
    super.key,
    required this.patient,
    required this.loadingRoutine,
    required this.hasRoutine,
    required this.loadingMedication,
    required this.hasMedication,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón editar paciente
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar paciente'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverAppBar),
            onPressed: onEdit,
          ),
        ),
        const SizedBox(height: 20),

        // Botón rutina
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: loadingRoutine
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(hasRoutine ? Icons.visibility : Icons.schedule, color: Colors.white),
            label: Text(hasRoutine ? 'Ver rutina' : 'Crear rutina',
                style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverAppBar),
            onPressed: loadingRoutine
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => hasRoutine
                            ? ViewRoutineScreen(patientId: patient.id)
                            : CreateRoutineScreen(patientId: patient.id, isEdit: false),
                      ),
                    );
                  },
          ),
        ),
        const SizedBox(height: 20),

        // Botón medicación
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: loadingMedication
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(hasMedication ? Icons.visibility : Icons.medication, color: Colors.white),
            label: Text(hasMedication ? 'Ver prescripción' : 'Crear prescripción',
                style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: loadingMedication
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => hasMedication
                            ? ViewPrescriptionScreen(patientId: patient.id)
                            : CreatePrescriptionScreen(patientId: patient.id),
                      ),
                    );
                  },
          ),
        ),
      ],
    );
  }
}