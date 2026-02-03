import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_medication_service.dart';

class CreateMedicationScheduleScreen extends StatefulWidget {
  final int patientId; // id del paciente

  const CreateMedicationScheduleScreen({super.key, required this.patientId});

  @override
  State<CreateMedicationScheduleScreen> createState() => _CreateMedicationScheduleScreenState();
}

class _CreateMedicationScheduleScreenState extends State<CreateMedicationScheduleScreen> {
  // Controllers para los TextField
  final _dose = TextEditingController();
  final _frequency = TextEditingController();

  // Variables para los datos seleccionados
  TimeOfDay? selectedHour;
  DateTime? startDate;
  DateTime? endDate;
  List<int> selectedDays = [];

  // Lista de medicamentos obtenidos del servicio
  List<dynamic> medications = [];
  dynamic selectedMedication; // medicamento seleccionado

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // ---------- Cargar medicamentos ----------
  // obtiene la lista de medicamentos desde el servicio
  Future<void> _loadMedications() async {
    try {
      medications = await CaregiverMedicationService().getMedications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando medicamentos: $e')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // ---------- Guardar rutina de medicamentos ----------
  Future<void> _saveSchedule() async {
    if (selectedMedication == null) { // si no se ha seleccionado medicamento
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
      return;
    }

    // Formatear la hora seleccionada
    final hour = selectedHour != null
        ? '${selectedHour!.hour.toString().padLeft(2, '0')}:${selectedHour!.minute.toString().padLeft(2, '0')}'
        : null;

    // Llamar al servicio para crear la rutina
    await CaregiverMedicationService().createMedicationSchedule(
      patientId: widget.patientId,
      medicationId: selectedMedication['id'],
      dose: int.parse(_dose.text),
      startDate: startDate != null
          ? startDate!.toIso8601String().split('T')[0] // toma la fecha en formato yyyy-MM-dd
          : null,
      endDate: endDate != null
          ? endDate!.toIso8601String().split('T')[0]
          : null,
      frequencyHours: _frequency.text.isNotEmpty
          ? int.parse(_frequency.text)
          : null,
      firstDoseTime: hour,
      daysOfWeek: selectedDays.isNotEmpty ? selectedDays : null,
    );

    Navigator.pop(context); // vuelve a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Rutina de medicamentos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Selector de medicamento ----------
            DropdownButtonFormField(
              initialValue: selectedMedication, // medicamento seleccionado
              hint: const Text('Selecciona un medicamento'),
              // mapea la lista de medicamentos a una lista de DropdownMenuItem
              items: medications.map((med) {
                return DropdownMenuItem(value: med, child: Text(med['name']));
              }).toList(),
              onChanged: (value) => setState(() => selectedMedication = value), // actualiza el medicamento seleccionado
            ),
            const SizedBox(height: 12),

            // ---------- Hora ----------
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context,initialTime: TimeOfDay.now()); // muestra el selector de hora
                if (picked != null) setState(() => selectedHour = picked); // actualiza la hora seleccionada
              },
              // Muestra el texto del botón, o la hora seleccionada si ya se eligió una
              child: Text(selectedHour == null ? 'Seleccionar hora' : selectedHour!.format(context),
              ),
            ),

            const SizedBox(height: 12),

            // ---------- Fecha inicio ----------
            ElevatedButton(
              // muestra el selector de fecha
              onPressed: () async {
                final picked = await showDatePicker( // guarda la fecha seleccionada
                  context: context,
                  initialDate: DateTime.now(), // fecha inicial es hoy
                  firstDate: DateTime(2000), // fecha mínima
                  lastDate: DateTime(2100), // fecha máxima
                );
                if (picked != null) setState(() => startDate = picked); // si se selecciona una fecha, la guarda
              },
              // al igual que antes, muestra la fecha seleccionada o el texto por defecto
              child: Text(startDate == null ? 'Seleccionar fecha inicio' : startDate!.toIso8601String().split('T')[0],
              ),
            ),

            const SizedBox(height: 12),

            // ---------- Fecha fin ----------
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => endDate = picked);
              },
              child: Text(endDate == null ? 'Seleccionar fecha fin' : endDate!.toIso8601String().split('T')[0],
              ),
            ),

            const SizedBox(height: 12),

            // ---------- Dosis ----------
            TextField(
              controller: _dose,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),

            const SizedBox(height: 12),

            // ---------- Frecuencia ----------
            TextField(
              controller: _frequency,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Frecuencia (horas)'),
            ),

            const SizedBox(height: 20),

            // ---------- Botón Guardar ----------
            ElevatedButton(
              onPressed: _saveSchedule,
              child: const Text('Guardar rutina'),
            ),
          ],
        ),
      ),
    );
  }
}
