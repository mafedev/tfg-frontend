import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/tts_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/shared/models/appointment.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:tfg_frontend/shared/widgets/emergency_call_fab.dart';

class PatientAppointmentScreen extends StatefulWidget {
  const PatientAppointmentScreen({super.key});

  @override
  State<PatientAppointmentScreen> createState() => _PatientAppointmentScreenState();
}

class _PatientAppointmentScreenState extends State<PatientAppointmentScreen> {
  final AppointmentService _service = AppointmentService();
  final TtsService _tts = TtsService();

  List<Appointment> appointments = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final data = await _service.getMyAppointments();

      setState(() {
        appointments = data;
        loading = false;
        error = null;
      });

      if (appointments.isNotEmpty) {
        _readAppointments();
      }
    } catch (e) {
      print(e);

      setState(() {
        loading = false;
        error = 'Error cargando citas';
      });

      AppSnackBar.showError(context, 'Error cargando citas');
    }
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);

      const monthNames = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre',
      ];

      final day = parsed.day.toString().padLeft(2, '0');
      final monthName = monthNames[parsed.month - 1];
      final year = parsed.year;

      return '$day de $monthName de $year';
    } catch (_) {
      return date;
    }
  }

  String _formatTime(String date) {
    try {
      final parsed = DateTime.parse(date);
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return date;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "COMPLETED":
        return AppColors.confirm;

      case "CANCELLED":
        return AppColors.alert;

      default:
        return AppColors.patientAccent;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case "COMPLETED":
        return "COMPLETADA";

      case "CANCELLED":
        return "CANCELADA";

      default:
        return "PENDIENTE";
    }
  }

  Future<void> _readAppointments() async {
    if (appointments.isEmpty) {
      await _tts.speak('No tienes citas.');
      return;
    }

    final buffer = StringBuffer();
    buffer.write(
      'Tienes ${appointments.length} cita${appointments.length == 1 ? '' : 's'} programada${appointments.length == 1 ? '' : 's'}. ',
    );

    for (final appointment in appointments) {
      final date = _formatDate(appointment.dateTime);
      final time = _formatTime(appointment.dateTime);
      buffer.write(
        'Cita: ${appointment.title}. Fecha: $date. Hora: $time. Lugar: ${appointment.location}. ',
      );
    }

    await _tts.speak(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    // si está cargando
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.patientBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // si hubo error
    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,

        appBar: const AppLogoAppBar(
          title: 'Mis citas',
          backgroundColor: AppColors.patientAppBar,
        ),

        floatingActionButton: const EmergencyCallFAB(),

        body: Center(
          child: Text(
            error!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // si no hay citas
    if (appointments.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,

        appBar: const AppLogoAppBar(
          title: 'Mis citas',
          backgroundColor: AppColors.patientAppBar,
        ),

        floatingActionButton: const EmergencyCallFAB(),

        body: const Center(
          child: Text(
            'No tienes citas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // si hay citas
    return Scaffold(
      backgroundColor: AppColors.patientBackground,

      appBar: const AppLogoAppBar(
        title: 'Mis citas',
        backgroundColor: AppColors.patientAppBar,
      ),

      floatingActionButton: const EmergencyCallFAB(),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: appointments.length + 1,

        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: _readAppointments,
                icon: const Icon(Icons.volume_up, size: 24),
                label: const Text(
                  'Leer citas en voz alta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.patientPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }

          final appointment = appointments[index - 1];

          final color = _statusColor(appointment.status);
          final formattedDate = _formatDate(appointment.dateTime);
          final formattedTime = _formatTime(appointment.dateTime);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.patientCard,
              borderRadius: BorderRadius.circular(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 36,
                      color: AppColors.patientPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appointment.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Fecha',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hora',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Lugar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.location,
                  style: const TextStyle(fontSize: 20, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.description,
                  style: const TextStyle(fontSize: 20, height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      _statusText(appointment.status),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
