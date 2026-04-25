import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/enums/tracking_status.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_routine_service.dart';
import 'package:tfg_frontend/models/routine.dart';

class ViewRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente cuya rutina se va a ver

  const ViewRoutineScreen({super.key, required this.patientId});

  @override
  State<ViewRoutineScreen> createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  // Servicio para obtener y manipular la rutina
  final RoutineService _routineService = RoutineService();
  Routine? routine; // contiene la rutina obtenida
  bool loading = true; // indica si se está cargando la rutina

  Map<int, int> trackingIdMap = {};
  Map<int, TrackingStatus> trackingStatusMap = {};

  // Cuando se inicia la pantalla, carga la rutina
  @override
  void initState() {
    super.initState();
    _loadRoutine();
    _loadTracking();
  }

  // -------------------- Carga rutina --------------------
  Future<void> _loadRoutine() async {
    try {
      final data = await _routineService.getRoutine(widget.patientId);

      if (data == null) {
        setState(() {
          routine = null;
          loading = false;
        });
        return;
      }

      setState(() {
        routine = Routine.fromJson(data);
      });
    } catch (e, stack) {
      setState(() {
        routine = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar rutina')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // -------------------- Carga tracking --------------------
  Future<void> _loadTracking() async {
    try {
      final data = await _routineService.getTracking(widget.patientId);

      final Map<int, int> tempIds = {};
      final Map<int, TrackingStatus> tempStatus = {};

      for (var t in data) {
        final itemId = t['itemId'];
        final trackingId = t['id'];
        final status = t['status'];

        tempIds[itemId] = trackingId;

        tempStatus[itemId] = TrackingStatus.values.firstWhere(
          (e) => e.name == status,
        );
      }

      setState(() {
        trackingIdMap = tempIds;
        trackingStatusMap = tempStatus;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar tracking: $e')));
    }
  }

  // -------------------- Marcar estado --------------------
  Future<void> _updateTrackingStatus(int itemId, TrackingStatus status) async {
    try {
      final trackingId = trackingIdMap[itemId];

      if (trackingId == null) {
        throw Exception("Tracking no encontrado para item $itemId");
      }

      await _routineService.updateTrackingStatus(
        trackingId: trackingId,
        status: status.name,
      );
      setState(() {
        trackingStatusMap[itemId] = status;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error actualizando tracking')));
    }
  }

  // -------------------- Chips --------------------
  Widget _trackingChips(int itemId) {
    final current = trackingStatusMap[itemId] ?? TrackingStatus.PENDING;

    return Wrap(
      spacing: 8,
      children: TrackingStatus.values.map((status) {
        final selected = status == current;

        return ChoiceChip(
          label: Text(status.name),
          selected: selected,
          onSelected: (_) {
            _updateTrackingStatus(itemId, status);
          },
        );
      }).toList(),
    );
  }

  // -------------------- Formatea hh:mm:ss -> hh:mm --------------------
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    // divide por ":" y toma solo hora y minuto
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    // muestra un indicador de carga mientras se obtiene la rutina
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Rutina', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: routine == null
            ? const Center(child: Text('No hay rutina asignada'))
            : ListView(
                children: [
                  const Text('Actividades'),
                  const SizedBox(height: 12),

                  ...routine!.items.map((item) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name),
                            Text(formatTime(item.time)),
                            _trackingChips(item.id),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 50),

                  ElevatedButton(
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
                      _loadTracking(); // refresca también el tracking
                    },
                    child: const Text('Editar rutina'),
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
                      onPressed: null,
                      child: const Text('Eliminar rutina'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
