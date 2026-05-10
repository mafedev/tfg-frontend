import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/models/routine.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class PatientRoutineScreen extends StatefulWidget {
  const PatientRoutineScreen({super.key});

  @override
  State<PatientRoutineScreen> createState() => _PatientRoutineScreenState();
}

class _PatientRoutineScreenState extends State<PatientRoutineScreen> {
  final RoutineService _service = RoutineService();

  Routine? routine; // almacena la rutina
  bool loading = true; // es para mostrar si la pantalla está cargando

  String? error;

  // Carga la rutina cuando se inicializa
  @override
  void initState() {
    super.initState();
    _loadRoutine();
  }

  Future<void> _loadRoutine() async {
    try {
      final result = await _service.getMyRoutine();
      setState(() {
        routine = result;
        loading = false;
        error = null;
      });
    } catch (_) {
      setState(() {
        routine = null;
        loading = false;
        error = 'Error al cargar la rutina';
      });
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';

    final parts = time.split(':');
    if (parts.length < 2) return time;

    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Mi rutina', backgroundColor: AppColors.patientAppBar),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : routine == null
          ? const Center(child: Text('No tienes rutina asignada'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Tu rutina diaria',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                if (routine!.items.isEmpty)
                  const Center(child: Text('No hay elementos en tu rutina'))
                else
                  ...routine!.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.patientCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: AppColors.patientPrimary,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          Text(_formatTime(item.time)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
