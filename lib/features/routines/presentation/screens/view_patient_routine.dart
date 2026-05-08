import 'package:flutter/material.dart';
import 'package:tfg_frontend/shared/enums/routine/routine_tracking_status.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/routines/presentation/screens/edit_routine_item_screen.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/models/routine.dart';

class ViewRoutineScreen extends StatefulWidget {
  final int patientId;

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

  DateTime selectedDate = DateTime.now();

  // Cuando se inicia la pantalla, carga la rutina
  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
    await _loadRoutine();
    await _loadTracking();
  }

  // -------------------- Carga rutina --------------------
  Future<void> _loadRoutine() async {
    try {
      final data = await _routineService.getRoutine(widget.patientId);

      setState(() {
        routine = data != null ? Routine.fromJson(data) : null;
        loading = false;
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
      final data = await _routineService.getTracking(patientId: widget.patientId, date: selectedDate);

      final ids = <int, int>{};
      final status = <int, TrackingStatus>{};

      for (var t in data) {
        ids[t['itemId']] = t['id'];
        status[t['itemId']] = TrackingStatus.values.firstWhere(
          (e) => e.name == t['status'],
        );
      }

      setState(() {
        trackingIdMap = ids;
        trackingStatusMap = status;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar tracking: $e')));
    }
  }

  // -------------------- Marcar estado --------------------
  Future<void> _updateTrackingStatus(int itemId, TrackingStatus s) async {
    try {
      final trackingId = trackingIdMap[itemId];

      if (trackingId == null) {
        return;
      }

      await _routineService.updateTrackingStatus(
        trackingId: trackingId,
        status: s.name,
      );
      setState(() {
        trackingStatusMap[itemId] = s;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error actualizando tracking')));
    }
  }

  // Borrar item de la rutina
  Future<void> deleteItem(int itemId) async {
    try {
      await _routineService.deleteItem(itemId);
      await loadAll();

    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error borrando item: $e")));
      }
    }
  }

  // Borrar rutina
  Future<void> deleteRoutine() async {
    await _routineService.deleteRoutine(widget.patientId);

    setState(() {
      routine = null;
    });
  }

  // Editar rutina
  Future<void> editRoutine() async {
    if (routine == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditRoutineScreen(routine: routine!)),
    );

    await loadAll();
  }

  Future<void> createItemDialog() async {
    final nameController = TextEditingController();
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (time != null) {
                  selectedTime = time;
                }
              },
              child: const Text("Seleccionar hora"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (routine == null) return;

              final timeString = selectedTime != null
                  ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00"
                  : "00:00:00";

              await _routineService.createItem(
                routineId: routine!.id,
                name: nameController.text,
                time: timeString,
                type: "OTHER",
              );

              Navigator.pop(context);
              await loadAll();
            },
            child: const Text("Crear"),
          )
        ],
      ),
    );
  }

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

    if (routine == null) {
      return const Scaffold(body: Center(child: Text("No rutina")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Rutina', backgroundColor: AppColors.caregiverAppBar),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.caregiverAppBar,
        onPressed: createItemDialog,
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          // -------- SELECTOR DE FECHA --------
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    setState(() {
                      selectedDate = selectedDate.subtract(const Duration(days: 1));
                    });
                    await _loadTracking();
                  },
                ),

                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    final tomorrow = selectedDate.add(const Duration(days: 1));

                    if (tomorrow.isAfter(DateTime.now())) return;

                    setState(() {
                      selectedDate = tomorrow;
                    });

                    await _loadTracking();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
        children: [
          ...routine!.items.map((item) {
            final current = trackingStatusMap[item.id] ?? TrackingStatus.PENDING;

            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.time ?? ""),

              trailing: DropdownButton(
                value: current,
                items: TrackingStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (s) {
                  if (s != null) _updateTrackingStatus(item.id, s);
                },
              ),

              onLongPress: () => deleteItem(item.id),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: editRoutine,
            child: const Text("Editar rutina"),
          ),
          // ---------- Botón para eliminar la rutina ----------
          ElevatedButton(
            onPressed: deleteRoutine,
            child: const Text("Eliminar rutina"),
          ),
        ],
      ),
          ),
        ],
      ),
    );
  }
}
