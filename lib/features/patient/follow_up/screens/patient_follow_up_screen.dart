import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/models/prescription_tracking.dart';
import 'package:tfg_frontend/services/patient_medication_service.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';

class PatientFollowUpScreen extends StatefulWidget {
  const PatientFollowUpScreen({super.key});

  @override
  State<PatientFollowUpScreen> createState() => _PatientFollowUpScreenState();
}

class _PatientFollowUpScreenState extends State<PatientFollowUpScreen> {
  final PatientMedicationService _service = PatientMedicationService();

  List<PrescriptionTracking> _tracking = []; // lista del seguimiento de medicamentos

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga el seguimiento de medicamentos para hoy
  Future<void> _load() async {
    try {
      final data = await _service.getMedicationTrackingForDate(DateTime.now()); // obtiene el seguimiento de medicamentos para hoy

      setState(() {
        _tracking = data; // actualiza la lista con la información que devuelve
      });
    } catch (e) {
      print(e);
    }
  }

  // Formatea la hora como 14:30
  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Seguimiento',backgroundColor: AppColors.patientAppBar),
      body: ListView.builder(
        itemCount: _tracking.length,
        itemBuilder: (context, i) {
          final med = _tracking[i];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre medicamento
              Text('Medicamento: ${med.medicationName}'),

              // Dosis
              Text('Dosis: ${med.dose}'),

              // Horas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: med.times.map((t) {
                  return Text('- ${_formatTime(t.scheduledTime)}');
                }).toList(),
              ),

              const Divider(),
            ],
          );
        },
      ),
    );
  }
}
