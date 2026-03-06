import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/secure_storage_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routine/models/routine.dart';
import 'package:tfg_frontend/features/routine/services/patient_routine_service.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';

class PatientRoutineScreen extends StatefulWidget {
  const PatientRoutineScreen({super.key});

  @override
  State<PatientRoutineScreen> createState() => _PatientRoutineScreenState();
}

class _PatientRoutineScreenState extends State<PatientRoutineScreen> {
  Routine? routine; // almacena la rutina
  bool isLoading = true; // es para mostrar si la pantalla está cargando

  // Carga la rutina cuando se inicializa
  @override
  void initState() {
    super.initState();
    loadRoutine();
  }

  // carga la rutina
  Future<void> loadRoutine() async {
    final token = await SecureStorageService().getToken(); // obtiene el token
    if (token == null) {
      setState(() => isLoading = false); // si no hay token, "deja de cargar"
      return;
    }

    // hace la petición para obtener la rutina, y lo guarda en result
    final result = await PatientRoutineService().getMyRoutine(token);

    // actualiza el estado con la rutina obtenida, y pone cargar a false
    setState(() {
      routine = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // si está cargando
    if (isLoading) {
      return Scaffold(
        appBar: const AppLogoAppBar(title: 'Mi Rutina', backgroundColor: AppColors.patientAppBar),
        body: const Center(
          child: CircularProgressIndicator(), // un indicador en lugar de solo texto
        ),
      );
    }

    // si no hay rutina
    if (routine == null) {
      return Scaffold(
        appBar: const AppLogoAppBar(title: 'Mi Rutina',backgroundColor: AppColors.patientAppBar),
        body: const Center(child: Text('No hay rutina')),
      );
    }

    // si hay rutina, la muestra
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Mi Rutina',backgroundColor: AppColors.patientAppBar),
      body: Container(
        color: AppColors.patientBackground,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra cada elemento de la rutina en una card
            _routineCard('Desayuno', formatTime(routine!.breakfastTime)),
            _routineCard('Almuerzo', formatTime(routine!.lunchTime)),
            _routineCard('Cena', formatTime(routine!.dinnerTime)),
            _routineCard('Baño', formatTime(routine!.bathTime)),
            _routineCard('Hidratación','Cada ${routine!.hydrationReminderHours} h',
            ),
          ],
        ),
      ),
    );
  }

  // Widget para cada card
  Widget _routineCard(String title, String value) {
    IconData icon;
    Color accentColor;

    // El color e ícono cambia según el tipo de item
    switch (title) {
      case 'Desayuno':
      case 'Almuerzo':
      case 'Cena':
      case 'Baño':
        icon = title == 'Baño' ? Icons.bathtub : Icons.free_breakfast;
        accentColor = title == 'Baño'
            ? AppColors.patientSecondary
            : AppColors.patientAccentGreen;
        // formatear la hora
        value = formatTime(value);
        break;
      case 'Hidratación':
      case 'Recordatorio de agua':
        icon = Icons.local_drink;
        accentColor = AppColors.patientPrimary;
        break;
      default:
        icon = Icons.check_circle_outline;
        accentColor = AppColors.patientPrimary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.patientCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accentColor.withOpacity(0.2),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// -------------------- Formatea hh:mm:ss -> hh:mm --------------------
String formatTime(String? time) {
  if (time == null || time.isEmpty) return '--:--';
  final parts = time.split(':');
  return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
}
