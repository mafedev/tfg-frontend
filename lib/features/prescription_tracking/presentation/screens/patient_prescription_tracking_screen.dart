import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/prescription_tracking/data/prescription_tracking_service.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class PatientPrescriptionTrackingScreen extends StatefulWidget {
  const PatientPrescriptionTrackingScreen({super.key});

  @override
  State<PatientPrescriptionTrackingScreen> createState() => _PatientPrescriptionTrackingScreenState();
}

class _PatientPrescriptionTrackingScreenState extends State<PatientPrescriptionTrackingScreen> {
  final PrescriptionTrackingService _service = PrescriptionTrackingService();

  List<PrescriptionTracking> _tracking = []; // lista del seguimiento de medicamentos

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga el seguimiento de medicamentos para hoy
  Future<void> _load() async {
    try {
      final data = await _service.getPrescriptionTrackingForDate(DateTime.now()); // obtiene el seguimiento de medicamentos para hoy

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
      appBar: const AppLogoAppBar(title: 'Prescripciones',backgroundColor: AppColors.patientAppBar),
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
