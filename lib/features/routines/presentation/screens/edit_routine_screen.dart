import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/models/routine.dart';
import 'package:tfg_frontend/shared/models/routine_item.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_primary_button.dart';
import 'package:tfg_frontend/shared/widgets/confirm_delete_dialog.dart';

class EditRoutineScreen extends StatefulWidget {
  final Routine routine;

  const EditRoutineScreen({super.key, required this.routine});

  @override
  State<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends State<EditRoutineScreen> {
  final RoutineService service = RoutineService();

  late List<RoutineItem> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.routine.items);
  }

  Future<void> saveChanges() async {
    for (final item in items) {
      await service.updateItem(
        itemId: item.id,
        name: item.name,
        time: item.time ?? "",
        type: item.type,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  // ---------------- Borrar item ----------------
  Future<void> deleteItem(int itemId) async {
    await service.deleteItem(itemId);
    setState(() {
      items.removeWhere((e) => e.id == itemId);
    });
  }

  // ---------------- Formato de la hora ----------------
  String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m:00";
  }

  // ---------------- Editar ----------------
  Future<void> editItemDialog(RoutineItem item) async {
    final nameController = TextEditingController(text: item.name);

    TimeOfDay? selectedTime;

    // intenta parsear hora existente si existe
    if (item.time != null && item.time!.isNotEmpty) {
      final parts = item.time!.split(":");
      if (parts.length >= 2) {
        selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Editar item"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // nombre
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),

                  const SizedBox(height: 10),

                  // hora
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: Text(
                      selectedTime == null
                          ? "Seleccionar hora"
                          : selectedTime!.format(context),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      item.name = nameController.text;

                      if (selectedTime != null) {
                        item.time = formatTime(selectedTime!);
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(
        title: 'Editar rutina',
        backgroundColor: AppColors.caregiverAppBar,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.time ?? "Sin hora",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.caregiverAppBar,
                              ),
                              onPressed: () => editItemDialog(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmDeleteDialog(
                                      title: "Eliminar actividad",
                                      message:
                                          "¿Seguro que quieres eliminar esta actividad?",
                                      onConfirm: () => deleteItem(item.id),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: AppPrimaryButton(text: "Guardar cambios", onPressed: saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
