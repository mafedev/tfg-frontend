import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/prescription_tracking/data/prescription_tracking_service.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/relation/data/relation_service.dart';
import 'package:tfg_frontend/core/services/notification_service.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:tfg_frontend/shared/widgets/emergency_call_fab.dart';

// Esta pantalla es para el paciente. Permite vincularse con un cuidador usando el código de vinculación
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // Controlador para el campo de texto donde el paciente escribe el código
  final TextEditingController codeController = TextEditingController();

  // Servicio para manejar la relación entre paciente y cuidador
  final RelationService _relationService = RelationService();
  // Servicio para obtener el tracking de medicamentos del paciente
  final PrescriptionTrackingService _medicationService = PrescriptionTrackingService();
  final RoutineService _routineService = RoutineService();
  // Servicio para programar notificaciones locales
  final NotificationService _notificationService = NotificationService();
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    try {
      await _notificationService.init();
      await _scheduleMedicationNotifications();
      await _scheduleRoutineNotifications();
    } catch (_) {}
  }

  // ---------------- MEDICAMENTOS ----------------
  Future<void> _scheduleMedicationNotifications() async {
    final tracking = await _medicationService.getMyPrescriptionTracking(
      DateTime.now(),
    );

    for (var med in tracking) {
      for (var t in med.times) {
        final dt = DateTime.parse(t.scheduledTime);

        if (dt.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: dt.hashCode,
            dateTime: dt,
            title: 'Toma de medicamento',
            body: 'Es hora de tomar ${med.medicationName}',
          );
        }
      }
    }
  }

  // ---------------- RUTINA ----------------
  Future<void> _scheduleRoutineNotifications() async {
    final token = await _storage.getToken();
    if (token == null) return;

    final routine = await _routineService.getMyRoutine();
    if (routine == null) return;

    final now = DateTime.now();

    for (var item in routine.items) {
      if (item.time == null || item.time!.isEmpty) continue;

      final parts = item.time!.split(":");
      if (parts.length < 2) continue;

      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (dt.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: item.id.hashCode,
          dateTime: dt,
          title: 'Rutina',
          body: 'Es hora de ${item.name}',
        );
      }
    }
  }

  // Función que se ejecuta cuando el paciente presiona el botón de vincular
  Future<void> _link() async {
    try {
      await _relationService.linkPatient(codeController.text.trim());

      AppSnackBar.showSuccess(context, 'Paciente conectado correctamente');
    } catch (e) {
      AppSnackBar.showError(context, 'Error conectando el paciente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título
      appBar: const AppLogoAppBar(
        title: 'Inicio',
        backgroundColor: AppColors.patientAppBar,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo de texto para escribir el código de vinculación
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de vinculación',
                ),
              ),
              const SizedBox(height: 16), // Espacio entre el campo y el botón
              // Botón para vincular
              ElevatedButton(onPressed: _link, child: const Text('Vincular')),
            ],
          ),
        ),
      ),

      // FAB de llamada de emergencia
      floatingActionButton: const EmergencyCallFAB(),
    );
  }
}
