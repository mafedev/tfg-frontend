import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'dart:developer';
import 'package:tfg_frontend/features/caregiver/screens/services/routine_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente, para crear la rutina

  // Constructor
  const CreateRoutineScreen({super.key, required this.patientId});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  // Es donde se van a guardar los horarios que se seleccionen
  TimeOfDay? breakfast;
  TimeOfDay? lunch;
  TimeOfDay? dinner;
  TimeOfDay? bath;

  bool enableHydration = false; // si quiere activar recordatorios de hidratación
  int waterReminder = 3; // cada cuánto quiere el recordatorio, valor por defecto 3 horas

  final RoutineService _routineService = RoutineService();

  // Muestra el time picker y devuelve la hora que seleccione
  Future<TimeOfDay?> _pickTime(TimeOfDay? initial) {
    return showTimePicker(
      context: context,
      initialTime:
          initial ??
          TimeOfDay.now(), // si no hay hora inicial, usa la hora actual
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
    // si falta algún horario, muestra el mensaje
    if ([breakfast, lunch, dinner, bath].contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los horarios')),
      );
      return;
    }

    try {
      // Le pasa los datos al servicio para crear la rutina
      await _routineService.createRoutine(
        patientId: widget.patientId,
        breakfastTime: _format(breakfast),
        lunchTime: _format(lunch),
        dinnerTime: _format(dinner),
        bathTime: _format(bath),
        enableHydration: enableHydration,
        waterReminder: waterReminder,
      );

      // si todo sale bien, muestra un mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutina guardada exitosamente'),
            duration: Duration(seconds: 2),
          ),
        );
        // Limpiar los campos después de guardar
        setState(() {
          breakfast = null;
          lunch = null;
          dinner = null;
          bath = null;
        });
      }
    } catch (e) { // si hay un error, lo muestra
      log('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Crear rutina', style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          // Filas con los horarios y el botón para guardar
          children: [
            Text('Rutina', style: const TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),),
            
            const SizedBox(height: 16),
            // ----------- Rutina -----------
            sectionCard(
              children: [
                sectionTitle('Horarios de comida'),
                const SizedBox(height: 12),

                _timeRow('Desayuno', breakfast, (t) => setState(() => breakfast = t)),
                _timeRow('Comida', lunch, (t) => setState(() => lunch = t)),
                _timeRow('Cena', dinner, (t) => setState(() => dinner = t)),
              ],
            ),

            const SizedBox(height: 12),

            // ----------- Aseo -----------
            sectionCard(
              children: [
                sectionTitle('Aseo'),
                const SizedBox(height: 12),
                _timeRow('Baño', bath, (t) => setState(() => bath = t)),
              ],
            ),

            const SizedBox(height: 12),

            // ----------- Hidratación -----------
            sectionCard(
              children: [
                sectionTitle('Hidratación'),

                SwitchListTile(
                  title: const Text('Recordatorios de hidratación'),
                  value: enableHydration,
                  onChanged: (v) {
                    setState(() {
                      enableHydration = v;
                      if (!v) waterReminder = 0;
                    });
                  },
                ),

                if (enableHydration)
                  Row(
                    children: [
                      const Text('Cada'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: waterReminder,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 hora')),
                          DropdownMenuItem(value: 2, child: Text('2 horas')),
                          DropdownMenuItem(value: 3, child: Text('3 horas')),
                          DropdownMenuItem(value: 4, child: Text('4 horas')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => waterReminder = v);
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),

            // Botón
            ElevatedButton(
              onPressed: _saveRoutine, // al presionarlo, llama a la función para guardarla
              child: const Text('Guardar rutina'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Widget para cada fila con la hora --------------------
  Widget _timeRow(String label, TimeOfDay? value, Function(TimeOfDay) onPick) {
    // InkWell para que toda la fila sea clickeable
    return InkWell(
      // cuando se toca la fila, abre el time picker
      onTap: () async { 
        final picked = await _pickTime(value); // guarda la hora seleccionada
        if (picked != null) onPick(picked); // si se seleccionó una hora, llama a la función onPick
      },

      // Estilo de la fila
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        // Fila con el label, la hora y el botón
        child: Row(
          children: [
            const SizedBox(width: 12),
            // ------------------- Texto del label -------------------
            // pone el label que se le pasa como parámetro, y ocupa todo el espacio disponible
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 8),

            // ------------------- Muestra la hora seleccionada -------------------
            Chip(
              // Texto dentro del chip, muestra la hora o --:-- si no hay
              label: Text(
                _format(value).isEmpty ? '--:--' : _format(value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey[100],
            ),
            const SizedBox(width: 8),

            // ------------------- Botón para elegir la hora -------------------
            TextButton(
              onPressed: () async { // cuando se presiona, muestra el time picker
                final picked = await _pickTime(value); // espera a que el usuario elija
                if (picked != null) onPick(picked); // si eligió algo, llama a la función para actualizar el estado
              },
              child: const Text('Elegir'), // texto del botón
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Widget para los títulos de cada sección --------------------
Widget sectionTitle(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

// --------------------- Widget de tarjeta para cada sección --------------------
Widget sectionCard({required List<Widget> children}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14), // padding interno
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}
