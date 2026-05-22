import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/tts_service.dart';
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
  final TtsService _tts = TtsService();

  bool loading = true;
  String patientName = 'Paciente';
  String todayText = '';

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    await _initNotifications();
    await _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    try {
      final username = await _storage.getUsername();
      final rawName = username?.trim() ?? '';
      final displayName = rawName.isNotEmpty
          ? _capitalize(rawName)
          : 'Paciente';

      setState(() {
        patientName = displayName;
        todayText = _formatToday();
        loading = false;
      });

      _speakWelcome(displayName);
    } catch (_) {
      setState(() {
        todayText = _formatToday();
        loading = false;
      });
    }
  }

  Future<void> _speakWelcome(String displayName) async {
    final message =
        'Hola $displayName. Hoy es ${_formatToday()}. Si necesitas ayuda, pulsa el botón rojo de emergencia o pide ayuda a tu cuidador.';
    await _tts.speak(message);
  }

  Future<void> _initNotifications() async {
    try {
      await _notificationService.init();
      await _scheduleMedicationNotifications();
      await _scheduleRoutineNotifications();
    } catch (_) {}
  }

  String _formatToday() {
    final now = DateTime.now();
    const months = [
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
    final month = months[now.month - 1];
    return '${now.day} de $month del ${now.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

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

  Widget _greetingCard() {
    return Card(
      color: AppColors.patientCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $patientName',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Hoy es $todayText',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkCard() {
    return Card(
      color: AppColors.patientCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Código de vinculación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Introduce el código que te dio tu cuidador para conectarte. Solo tienes que escribirlo y presionar "Vincular".',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Escribe el código aquí',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        appBar: AppLogoAppBar(
          title: 'Inicio',
          backgroundColor: AppColors.patientAppBar,
        ),
        backgroundColor: AppColors.patientBackground,
        body: Center(child: CircularProgressIndicator()),
        floatingActionButton: EmergencyCallFAB(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.patientBackground,
      appBar: const AppLogoAppBar(
        title: 'Inicio',
        backgroundColor: AppColors.patientAppBar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _greetingCard(),
            const SizedBox(height: 28),
            _linkCard(),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _link,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.patientPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text(
                'Vincular cuidador',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: AppColors.patientCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Consejo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Si necesitas ayuda, pulsa el botón rojo de emergencia o pide ayuda a tu cuidador.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: const EmergencyCallFAB(),
    );
  }
}
