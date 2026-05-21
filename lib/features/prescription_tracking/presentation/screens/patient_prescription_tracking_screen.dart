import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/tts_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/prescription_tracking/data/prescription_tracking_service.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/emergency_call_fab.dart';

class PatientPrescriptionTrackingScreen extends StatefulWidget {
  const PatientPrescriptionTrackingScreen({super.key});

  @override
  State<PatientPrescriptionTrackingScreen> createState() => _PatientPrescriptionTrackingScreenState();
}

class _PatientPrescriptionTrackingScreenState extends State<PatientPrescriptionTrackingScreen> {
  final PrescriptionTrackingService _service = PrescriptionTrackingService();

  List<PrescriptionTracking> _tracking = []; // lista del seguimiento de medicamentos
  final TtsService _tts = TtsService();
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga el seguimiento de medicamentos para hoy
  Future<void> _load() async {
    try {
      final data = await _service.getMyPrescriptionTracking(DateTime.now());

      setState(() {
        _tracking = data; // actualiza la lista con la información que devuelve
        loading = false;
        error = null;
      });

      // lectura automática
      if (_tracking.isNotEmpty) {
        final allText = StringBuffer();

        allText.write("Hoy tienes medicación. ");

        for (final med in _tracking) {
          allText.write("Medicamento ${med.medicationName}. ");
        }

        _tts.speak(allText.toString());
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error cargando prescripciones';
      });
    }
  }

  void _readMedication(PrescriptionTracking med) {
    final buffer = StringBuffer();

    buffer.write("Medicamento ${med.medicationName}. ");
    buffer.write("Dosis ${med.dose}. ");

    for (final t in med.times) {
      final dt = DateTime.parse(t.scheduledTime);
      final time =
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

      buffer.write(
        "A las $time está ${t.status == 'TAKEN' ? 'tomado' : 'pendiente'}. ",
      );
    }

    _tts.speak(buffer.toString());
  }

  // Formatea la hora como 14:30
  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return '--:--';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'TAKEN':
        return AppColors.patientAccentGreen;
      default:
        return AppColors.patientAccent;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'TAKEN':
        return 'TOMADO';
      default:
        return 'PENDIENTE';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mis medicamentos',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.patientAppBar),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    // Si hubo error
    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mis medicamentos',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    // Si no hay medicación
    if (_tracking.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mis medicamentos',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: const Center(
          child: Text(
            'No tienes medicación hoy',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    // Pantalla principal
    return Scaffold(
      backgroundColor: AppColors.patientBackground,
      appBar: const AppLogoAppBar(
        title: 'Mis medicamentos',
        backgroundColor: AppColors.patientAppBar,
      ),
      floatingActionButton: const EmergencyCallFAB(),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tracking.length,
        itemBuilder: (context, i) {
          final med = _tracking[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.patientCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        med.medicationName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        size: 34,
                        color: AppColors.patientPrimary,
                      ),
                      onPressed: () {
                        _readMedication(med);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Dosis: ${med.dose}',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 12),

                ...med.times.map((t) {
                  final color = _statusColor(t.status);
                  final text = _statusText(t.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t.status == 'TAKEN'
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: color,
                          size: 28,
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            _formatTime(t.scheduledTime),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
