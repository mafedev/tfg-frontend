import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_medication_service.dart';

class CreateMedicationScheduleScreen extends StatefulWidget {
  final int patientId; // id del paciente
  final Map<String, dynamic>? existingSchedule; // para editar

  const CreateMedicationScheduleScreen({super.key, required this.patientId,this.existingSchedule});

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

  // Días de la semana
  final Map<int, String> weekDays = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // ---------- Cargar medicamentos ----------
  // obtiene la lista de medicamentos desde el servicio
  Future<void> _loadMedications() async {
    try {
      medications = await CaregiverMedicationService().getMedications(); // obtiene la lista de medicamentos

      // si se está editando una rutina existente, carga sus datos
      if (widget.existingSchedule != null) { // si hay una rutina existente
        final sched = widget.existingSchedule!; // obtiene la rutina
        
        // llena los campos con los datos
        _dose.text = sched['dose'].toString(); // guarda la dosis
        _frequency.text = sched['frequencyHours']?.toString() ?? ''; // guarda la frecuencia
        startDate = sched['startDate'] != null ? DateTime.parse(sched['startDate']) : null;
        endDate = sched['endDate'] != null ? DateTime.parse(sched['endDate']) : null;
        selectedDays = sched['daysOfWeek'] != null ? List<int>.from(sched['daysOfWeek']) : [];

        // guarda la hora del primer dosis
        if (sched['firstDoseTime'] != null) {
          final parts = sched['firstDoseTime'].split(':');
          selectedHour = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        
        // busca el medicamento seleccionado en la lista de medicamentos
        selectedMedication = medications.firstWhere(
          (m) => m['id'] == sched['medication']['id'], // compara por id
          orElse: () => null, // si no lo encuentra, devuelve null
        );
      }
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

    final service = CaregiverMedicationService();

    // si no hay rutina existente, crea una nueva
    if (widget.existingSchedule == null) {
      
      // Crea una nueva rutina
      await service.createMedicationSchedule(
        // llena los datos
        patientId: widget.patientId,
        medicationId: selectedMedication['id'],
        dose: int.parse(_dose.text),
        startDate: startDate?.toIso8601String().split('T')[0], // lo pasa en formato YYYY-MM-DD
        endDate: endDate?.toIso8601String().split('T')[0],
        frequencyHours: _frequency.text.isNotEmpty
            ? int.parse(_frequency.text)
            : null,
        firstDoseTime: hour,
        daysOfWeek: selectedDays.isNotEmpty ? selectedDays : null,
      );
    } else {

      // Si hay una rutina existente, la actualiza
      await service.updateMedicationSchedule(
        scheduleId: widget.existingSchedule!['id'],
        patientId: widget.patientId,
        medicationId: selectedMedication['id'],
        dose: int.parse(_dose.text),
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
        frequencyHours: _frequency.text.isNotEmpty
            ? int.parse(_frequency.text)
            : null,
        firstDoseTime: hour,
        daysOfWeek: selectedDays.isNotEmpty ? selectedDays : null,
      );
    }

    Navigator.pop(context); // vuelve a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppLogoAppBar(title: widget.existingSchedule == null ? 'Nueva rutina' : 'Editar rutina', backgroundColor: AppColors.caregiverAppBar),
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
            const SizedBox(height: 12),

            // ---------- Días de la semana ----------
            Text('Selecciona los días:', style: const TextStyle(fontWeight: FontWeight.bold),),
            Wrap( // para que los chips se ajusten al ancho disponible
              spacing: 8, // espacio entre chips
              // genera un FilterChip por cada día de la semana, usando weekDays
              children: weekDays.entries.map((entry) {
                final dayNumber = entry.key;
                final dayName = entry.value;
                final isSelected = selectedDays.contains(dayNumber);
                return FilterChip(
                  label: Text(dayName),
                  selected: isSelected,
                  // al cambiar el estado del chip, actualiza la lista de días seleccionados
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedDays.add(dayNumber);
                      } else {
                        selectedDays.remove(dayNumber);
                      }
                    });
                  },
                );
              }).toList(),
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
