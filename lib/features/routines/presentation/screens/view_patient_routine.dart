import 'package:flutter/material.dart';
import 'package:tfg_frontend/shared/enums/routine/routine_tracking_status.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_fab.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/routines/presentation/screens/edit_routine_screen.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/models/routine.dart';
import 'package:tfg_frontend/shared/widgets/confirm_delete_dialog.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cargar rutina')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // -------------------- Carga tracking --------------------
  Future<void> _loadTracking() async {
    try {
      final data = await _routineService.getTracking(
        patientId: widget.patientId,
        date: selectedDate,
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error actualizando tracking')),
      );
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

  void confirmDeleteRoutine() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: "Eliminar rutina",
        message: "¿Seguro que quieres eliminar esta rutina? Esta acción no se puede deshacer.",
        onConfirm: () async {
          await deleteRoutine();
        },
      ),
    );
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
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      await _loadTracking();
    }
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
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppLogoAppBar(
          title: 'Rutina',
          backgroundColor: AppColors.caregiverAppBar,
        ),

        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No hay rutina",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppLogoAppBar(
        title: 'Rutina',
        backgroundColor: AppColors.caregiverAppBar,

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),

            onSelected: (value) async {
              if (value == 'edit') {
                await editRoutine();
              }

              if (value == 'delete') {
                confirmDeleteRoutine();
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.black),
                    SizedBox(width: 10),
                    Text('Editar rutina'),
                  ],
                ),
              ),

              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Eliminar rutina',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: AppFAB(
        onPressed: createItemDialog
      ),

      body: Column(
        children: [
          // -------- SELECTOR DE FECHA --------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () async {
                      setState(() {
                        selectedDate = selectedDate.subtract(
                          const Duration(days: 1),
                        );
                      });

                      await _loadTracking();
                    },
                  ),

                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.caregiverAppBar,
                            ),

                            const SizedBox(width: 10),

                            Text(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () async {
                      final tomorrow = selectedDate.add(
                        const Duration(days: 1),
                      );

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
          ),
          Expanded(
            child: ListView(
              children: routine!.items.map((item) {
                final current =
                    trackingStatusMap[item.id] ?? TrackingStatus.PENDING;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.caregiverAppBar.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        color: AppColors.caregiverAppBar,
                      ),
                    ),

                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.time ?? "Sin hora",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),

                    trailing: DropdownButton<TrackingStatus>(
                      value: current,
                      underline: const SizedBox(),

                      borderRadius: BorderRadius.circular(12),

                      items: TrackingStatus.values
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.name)),
                          )
                          .toList(),

                      onChanged: (s) {
                        if (s != null) {
                          _updateTrackingStatus(item.id, s);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        ],
      ),
    );
  }
}
