import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_medication_service.dart';
import 'package:tfg_frontend/core/enums/prescription.dart';

class CreateMedicationScheduleScreen extends StatefulWidget {
  final int patientId; // id del paciente
  final Map<String, dynamic>? existingSchedule; // para editar

  const CreateMedicationScheduleScreen({super.key, required this.patientId, this.existingSchedule});

  @override
  State<CreateMedicationScheduleScreen> createState() => _CreateMedicationScheduleScreenState();
}

class _CreateMedicationScheduleScreenState extends State<CreateMedicationScheduleScreen> {
  // Controllers para los TextField
  final _dose = TextEditingController();
  final _frequency = TextEditingController();
  final _notes = TextEditingController();

  // Variables para los datos seleccionados
  TimeOfDay? selectedHour;
  DateTime? startDate;
  DateTime? endDate;
  List<int> selectedDays = [];

  // Lista de medicamentos obtenidos del servicio
  List<dynamic> medications = [];

  dynamic selectedMedication; // medicamento seleccionado en el Dropdown
  String selectedStatus = 'ACTIVE'; // estado seleccionado en el Dropdown, por defecto 'ACTIVE'

  DoseUnit? selectedDoseUnit; // unidad de dosis seleccionada en el Dropdown

  bool loading = true;
  int? prescriptionId; // id de la prescripción, debug

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

  // Estados posibles para la prescripción
  final List<String> statuses = ['ACTIVE', 'SUSPENDED', 'COMPLETED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // ---------- Cargar medicamentos ----------
  // obtiene la lista de medicamentos desde el servicio
  Future<void> _loadMedications() async {
    try {
      final medicationService = CaregiverMedicationService(); // instancia del servicio de medicamentos
      final loadedMedications = await medicationService.getMedications(); // obtiene la lista de medicamentos desde el servicio
      
      // Actualiza el estado con los medicamentos cargados
      setState(() {
        medications = loadedMedications; // guarda la lista de medicamentos
        // Si hay medicamentos y no se ha seleccionado ninguno, selecciona el primero
        if (medications.isNotEmpty && selectedMedication == null) {
          selectedMedication = medications[0];
        }
      });

      // Si se está editando una rutina existente, carga sus datos
      if (widget.existingSchedule != null) {
        final sched = widget.existingSchedule!; // datos de la rutina existente
        prescriptionId = sched['id'] as int?; // guarda el id de la prescripción para futuras actualizaciones
        _dose.text = sched['dose'].toString(); // carga la dosis en el TextField
        _frequency.text = sched['frequencyHours']?.toString() ?? ''; // carga la frecuencia en el TextField, si existe
        _notes.text = sched['notes']?.toString() ?? ''; // carga las notas en el TextField, si existen
        selectedStatus = sched['status']?.toString() ?? 'ACTIVE'; // carga el estado, si existe, o deja 'ACTIVE' por defecto
        startDate = sched['startDate'] != null ? DateTime.parse(sched['startDate']) : null; // carga la fecha de inicio, si existe
        endDate = sched['endDate'] != null ? DateTime.parse(sched['endDate']) : null; // carga la fecha de fin, si existe
        
        // Cargar días de la semana, si existen
        // La API devuelve los días como una lista de strings, por ejemplo: ["MONDAY", "WEDNESDAY"], por lo que se convierten a números para la lógica de selección
        if (sched['daysOfWeek'] != null && sched['daysOfWeek'] is List) {
          selectedDays = (sched['daysOfWeek'] as List).map((day) { // convierte cada día de string a número
            final dayStr = day.toString().toUpperCase(); // convierte a mayúsculas para comparación
            // dependiendo del string, devuelve el número correspondiente al día de la semana (1 para lunes, 2 para martes, etc.)
            switch (dayStr) {
              case 'MONDAY': return 1;
              case 'TUESDAY': return 2;
              case 'WEDNESDAY': return 3;
              case 'THURSDAY': return 4;
              case 'FRIDAY': return 5;
              case 'SATURDAY': return 6;
              case 'SUNDAY': return 7;
              default: return 0;
            }
          }).where((d) => d != 0).toList(); 
        }
        
        // Cargar hora de primera dosis
        if (sched['firstDoseTime'] != null) {
          final parts = sched['firstDoseTime'].split(':');
          selectedHour = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        
        // busca el medicamento seleccionado en la lista de medicamentos cargados, comparando por id
        final medicationId = sched['medication']['id'];
        
        selectedMedication = medications.firstWhere(
          (m) => (m['id'] as int?) == medicationId,
          orElse: () => null,
        );
        
        // carga la unidad de dosis seleccionada, comparando por nombre (por ejemplo, 'MG', 'ML', etc.)
        final doseUnitStr = sched['doseUnit']?.toString() ?? 'MG';
        selectedDoseUnit = DoseUnit.values.firstWhere(
          (u) => u.name.toUpperCase() == doseUnitStr.toUpperCase(),
          orElse: () => DoseUnit.MG,
        );
        
        // Actualizar UI con los datos cargados
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando medicamentos: $e')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // ---------- Guardar rutina de medicamentos ----------
  Future<void> _saveSchedule() async {
    if (selectedMedication == null || selectedDoseUnit == null) { // si no se ha seleccionado un medicamento o una unidad de dosis, muestra un error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
      return;
    }

    // Formatear la hora seleccionada
    final hour = selectedHour != null
        ? '${selectedHour!.hour.toString().padLeft(2, '0')}:${selectedHour!.minute.toString().padLeft(2, '0')}'
        : null;

    final service = CaregiverPrescriptionService();

    try {
      // Si existe prescriptionId, es una edición
      if (prescriptionId != null) {
        await service.updatePrescription(
          prescriptionId: prescriptionId!,
          patientId: widget.patientId,
          medicationId: selectedMedication['id'],
          dose: double.parse(_dose.text),
          doseUnit: selectedDoseUnit!,
          frequencyHours: _frequency.text.isNotEmpty ? int.parse(_frequency.text) : null,
          startDate: startDate?.toIso8601String().split('T')[0], // lo pasa en formato YYYY-MM-DD
          endDate: endDate?.toIso8601String().split('T')[0],
          firstDoseTime: hour,
          daysOfWeek: selectedDays.isNotEmpty ? selectedDays : null,
          notes: _notes.text,
          status: selectedStatus,
        );
      } else {
        // Si no, es una creación
        await service.createPrescription(
          patientId: widget.patientId,
          medicationId: selectedMedication['id'],
          dose: double.parse(_dose.text),
          doseUnit: selectedDoseUnit!,
          frequencyHours: _frequency.text.isNotEmpty ? int.parse(_frequency.text) : null,
          startDate: startDate?.toIso8601String().split('T')[0],
          endDate: endDate?.toIso8601String().split('T')[0],
          firstDoseTime: hour,
          daysOfWeek: selectedDays.isNotEmpty ? selectedDays : null,
          notes: _notes.text,
          status: selectedStatus,
        );
      }
      Navigator.pop(context); // vuelve a la pantalla anterior después de guardar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppLogoAppBar(
        title: widget.existingSchedule == null ? 'Nueva rutina' : 'Editar rutina',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- Selector de medicamento ----------
            DropdownButtonFormField(
              value: selectedMedication,
              hint: const Text('Selecciona un medicamento'),
              items: medications.map((m) => DropdownMenuItem(value: m, child: Text(m['name']))).toList(),
              onChanged: (value) => setState(() => selectedMedication = value),
            ),
            const SizedBox(height: 12),

            // ---------- Selector de unidad de dosis ----------
            DropdownButtonFormField<DoseUnit>(
              value: selectedDoseUnit,
              hint: const Text('Selecciona unidad de dosis'),
              items: DoseUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
              onChanged: (value) => setState(() => selectedDoseUnit = value),
            ),
            const SizedBox(height: 12),

            // ---------- Campo de dosis ----------
            TextField(
              controller: _dose,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 12),

            // ---------- Campo de frecuencia ----------
            TextField(
              controller: _frequency,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Frecuencia (horas)'),
            ),
            const SizedBox(height: 12),
            
            // ---------- Selector de hora de primera dosis ----------
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setState(() => selectedHour = picked);
              },
              child: Text(selectedHour == null ? 'Seleccionar primera dosis' : 'Primera dosis: ${selectedHour!.format(context)}'),
            ),
            const SizedBox(height: 12),

            // ---------- Selector de fecha de inicio ----------
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => startDate = picked);
              },
              child: Text(startDate == null ? 'Seleccionar fecha inicio' : 'Inicio: ${startDate!.toIso8601String().split('T')[0]}'),
            ),
            const SizedBox(height: 12),

            // ---------- Selector de fecha de fin ----------
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
              child: Text(endDate == null ? 'Seleccionar fecha fin' : 'Fin: ${endDate!.toIso8601String().split('T')[0]}'),
            ),
            const SizedBox(height: 12),

            // ---------- Campo de notas ----------
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Ej: Tomar con comida',
              ),
            ),
            const SizedBox(height: 12),

            // ---------- Dropdown de estado ----------
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => selectedStatus = value!),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 12),

            // ---------- Selector de días de la semana ----------
            Text('Selecciona los días:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: weekDays.entries.map((entry) {
                final dayNumber = entry.key;
                final dayName = entry.value;
                final isSelected = selectedDays.contains(dayNumber);
                return FilterChip(
                  label: Text(dayName),
                  selected: isSelected,
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
            ElevatedButton(
              onPressed: _saveSchedule,
              child: Text(widget.existingSchedule == null ? 'Crear prescripción' : 'Actualizar prescripción'),
            ),
          ],
        ),
      ),
    );
  }
}