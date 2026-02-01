import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/screens/routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/screens/services/caregiver_routine_service.dart';

class ViewRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente cuya rutina se va a ver

  const ViewRoutineScreen({super.key, required this.patientId});

  @override
  State<ViewRoutineScreen> createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  // Servicio para obtener la rutina
  final RoutineService _routineService = RoutineService();
  Map<String, dynamic>? routine; // contiene la rutina obtenida
  bool loading = true; // indica si se está cargando la rutina

  // Cuando se inicia la pantalla, carga la rutina
  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  // Carga la rutina desde el backend
  Future<void> _loadRoutine() async {
    try {
      routine = await _routineService.getRoutine(widget.patientId); // obtiene la rutina
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar rutina')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    // muestra un indicador de carga mientras se obtiene la rutina
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // si no hay rutina, muestra un mensaje
    if (routine == null) {
      return const Scaffold(
        body: Center(child: Text('No hay rutina')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rutina')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // muestra los detalles de la rutina
          children: [
            Text('Desayuno: ${routine!['breakfastTime']}'),
            Text('Comida: ${routine!['lunchTime']}'),
            Text('Cena: ${routine!['dinnerTime']}'),
            Text('Baño: ${routine!['bathTime']}'),
            const SizedBox(height: 20),

            // ---------- Botón para editar la rutina ----------
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRoutineScreen(
                      patientId: widget.patientId,
                      isEdit: true,
                    ),
                  ),
                );
              },
              child: const Text('Editar rutina'),
            )
          ],
        ),
      ),
    );
  }
}
