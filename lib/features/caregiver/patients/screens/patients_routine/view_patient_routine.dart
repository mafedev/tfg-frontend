import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_routine_service.dart';

class ViewRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente cuya rutina se va a ver

  const ViewRoutineScreen({super.key, required this.patientId});

  @override
  State<ViewRoutineScreen> createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  // Servicio para obtener y manipular la rutina
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
    setState(() => loading = true);
    try {
      routine = await _routineService.getRoutine(widget.patientId); // obtiene la rutina
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar rutina')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // -------------------- Elimina la rutina --------------------
  Future<void> _deleteRoutine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: const Text('¿Seguro que quieres eliminar esta rutina?'),
        // Dependiendo de la opción elegida, devuelve true o false
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return; // si cancela, no hace nada

    try {
      await _routineService.deleteRoutine(widget.patientId); // llama al DELETE del backend
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rutina eliminada')));
      setState(() => routine = null); // actualiza estado para reflejar eliminación
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar rutina: $e')));
    }
  }

  // --------------------- Widget para mostrar un ítem de la rutina --------------------
  Widget _routineItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.caregiverPrimary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    // muestra un indicador de carga mientras se obtiene la rutina
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Rutina', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: routine == null
            ? const Center(child: Text('No hay rutina asignada'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ---------- Muestra los horarios de la rutina ----------
                children: [
                  _routineItem('Desayuno', routine!['breakfastTime'], Icons.free_breakfast),
                  _routineItem('Comida', routine!['lunchTime'], Icons.lunch_dining),
                  _routineItem('Cena', routine!['dinnerTime'], Icons.dinner_dining),
                  _routineItem('Baño', routine!['bathTime'], Icons.bathtub),

                  const SizedBox(height: 30),

                  // ---------- Botón para editar la rutina ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caregiverPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Navega a la pantalla de edición
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateRoutineScreen(
                              patientId: widget.patientId,
                              isEdit: true,
                            ),
                          ),
                        );
                        // Recarga la rutina después de editar
                        _loadRoutine();
                      },
                      child: const Text('Editar rutina'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------- Botón para eliminar la rutina ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.delete,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _deleteRoutine,
                      child: const Text('Eliminar rutina'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
