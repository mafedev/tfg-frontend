import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'dart:developer';
import 'package:tfg_frontend/features/caregiver/screens/services/caregiver_routine_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente, para crear la rutina
  final bool isEdit; // indica si se está editando una rutina existente

  // Constructor
  const CreateRoutineScreen({super.key,required this.patientId,required this.isEdit,});

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
  bool loading = true; // indica si está cargando


  // -------------------- Carga la rutina si se está editando --------------------
  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _loadRoutine();
    } else {
      loading = false;
    }
  }

  // -------------------- Carga la rutina existente --------------------
  Future<void> _loadRoutine() async {
    try {
      final routine = await _routineService.getRoutine(widget.patientId); // obtiene la rutina del paciente
      if (routine != null) { // si existe, llena los campos con los datos
        setState(() {
          breakfast = _parseTime(routine['breakfastTime']);
          lunch = _parseTime(routine['lunchTime']);
          dinner = _parseTime(routine['dinnerTime']);
          bath = _parseTime(routine['bathTime']);
          enableHydration = routine['enableHydration'] ?? false;
          waterReminder = routine['waterReminder'] ?? 3;
        });
      }
    } catch (e) {
      log('Error cargando rutina: $e');
    } finally {
      // actualiza el estado para indicar que ya no está cargando
      setState(() {
        loading = false;
      });
    }
  }

  // Convierte una cadena "hh:mm" a TimeOfDay
  TimeOfDay? _parseTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

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
    // intenta guardar la rutina
    try {
      if (widget.isEdit) { // si se está editando, llama a la función de actualizar
        await _routineService.updateRoutine(
          patientId: widget.patientId,
          breakfastTime: _format(breakfast),
          lunchTime: _format(lunch),
          dinnerTime: _format(dinner),
          bathTime: _format(bath),
          enableHydration: enableHydration,
          waterReminder: waterReminder,
        );
      } else { // si no, crea una nueva rutina
        await _routineService.createRoutine(
          patientId: widget.patientId,
          breakfastTime: _format(breakfast),
          lunchTime: _format(lunch),
          dinnerTime: _format(dinner),
          bathTime: _format(bath),
          enableHydration: enableHydration,
          waterReminder: waterReminder,
        );
    }

    // si todo va bien, muestra un mensaje y vuelve atrás
    if (mounted) Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverAppBar,
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
