import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_routine_service.dart';
import 'package:tfg_frontend/models/routine.dart';
import 'package:tfg_frontend/models/routine_item.dart';

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
      appBar: AppBar(
        title: const Text("Editar rutina"),
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.time ?? ""),

                  // editar
                  onTap: () => editItemDialog(item),

                  // borrar
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(item.id),
                  ),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: saveChanges,
            child: const Text("Guardar cambios"),
          ),
        ],
      ),
    );
  }
}
