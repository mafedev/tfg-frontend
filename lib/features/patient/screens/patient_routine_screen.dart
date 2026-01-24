import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/secure_storage_service.dart';
import 'package:tfg_frontend/features/routine/models/routine.dart';
import 'package:tfg_frontend/features/routine/services/patient_routine_service.dart';

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
      return Scaffold(body: Center(child: Text('Cargando rutina...')));
    }

    // si no hay rutina
    if (routine == null) {
      return const Center(child: Text('No hay rutina'));
    }

    // si hay rutina, la muestra
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Desayuno: ${routine!.breakfastTime}'),
        Text('Almuerzo: ${routine!.lunchTime}'),
        Text('Cena: ${routine!.dinnerTime}'),
        Text('Baño: ${routine!.bathTime}'),
        Text('Hidratación: ${routine!.enableHydration}'),
        Text('Cada ${routine!.waterReminder} h'),
      ],
    );
  }
}
