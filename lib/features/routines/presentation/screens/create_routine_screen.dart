import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_primary_button.dart';
import 'package:tfg_frontend/shared/widgets/app_secondary_icon_button.dart';

class CreateRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente, para crear la rutina
  final bool isEdit; // indica si se está editando una rutina existente

  // Constructor
  const CreateRoutineScreen({
    super.key,
    required this.patientId,
    required this.isEdit,
  });

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final RoutineService _routineService = RoutineService();
  bool loading = false;
  int? routineId;

  List<Map<String, dynamic>> items = [];

  void _addItem() async {
    final nameController = TextEditingController();
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva actividad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (t != null) selectedTime = t;
              },
              child: const Text('Seleccionar hora'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty || selectedTime == null) return;

              setState(() {
                items.add({
                  "name": nameController.text,
                  "time": _format(selectedTime!),
                  "type": "OTHER",
                });
              });

              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // cambia el formato a hh:mm
  String _format(TimeOfDay? t) {
    if (t == null) return ''; // si no hay hora, no devuelve nada
    // devuelve la hora y los minutos con dos dígitos, ej: 09:05
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // -------------------- Guarda la rutina usando el RoutineService --------------------
  void _saveRoutine() async {
    setState(() => loading = true);

    try {
      final id = await _routineService.createRoutine(widget.patientId);
      routineId = id;

      for (var item in items) {
        await _routineService.createItem(
          routineId: routineId!,
          name: item['name'],
          time: item['time'],
          type: item['type'],
        );
      }

      // si todo va bien, muestra un mensaje y vuelve atrás
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => loading = false);
  }

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Crear rutina',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- Actividades ----------------
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No hay actividades', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final item = items[i];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.caregiverAppBar.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.schedule, color: AppColors.caregiverAppBar),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item['time'], style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() => items.removeAt(i));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            // ---------------- Agregar actividad ----------------
            AppSecondaryIconButton(
                text: 'Añadir actividad',
                icon: Icons.add,
                onPressed: _addItem,
              ),

            const SizedBox(height: 12),

            // ---------------- Guardar----------------
            AppPrimaryButton(
              text: "Guardar rutina",
              onPressed: _saveRoutine,
              loading: loading,
            ),
          ],
        ),
      ),
    );
  }
}
