import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/prescription/data/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/medication/data/caregiver_medication_service.dart';
import 'package:tfg_frontend/shared/enums/medication/prescription_status.dart';
import 'package:tfg_frontend/shared/dtos/medication/prescription_request.dart';
import 'package:tfg_frontend/shared/dtos/medication/medication_response.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  final int patientId; // id del paciente
  final Map<String, dynamic>? existingPrescription; // para editar

  const CreatePrescriptionScreen({super.key, required this.patientId, this.existingPrescription});

  @override
  State<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  // Controllers para los TextField
  final _dose = TextEditingController();
  final _frequency = TextEditingController();
  final _notes = TextEditingController();

  // Variables para los datos seleccionados
  TimeOfDay? selectedHour;
  DateTime? startDate;
  DateTime? endDate;
  // Lista de medicamentos obtenidos del servicio
  List<MedicationResponse> medications = [];
  MedicationResponse? selectedMedication;

  String selectedStatus = 'ACTIVE'; // estado seleccionado en el Dropdown, por defecto 'ACTIVE'

  DoseUnit? selectedDoseUnit; // unidad de dosis seleccionada en el Dropdown

  bool loading = true;
  int? prescriptionId; // id de la prescripción, debug


  // Estados posibles para la prescripción
  final List<String> statuses = ['ACTIVE', 'SUSPENDED', 'COMPLETED', 'CANCELLED'];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // ---------- Estilo de inputs ----------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.4),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide(color: Colors.deepPurple.shade500, width: 2),
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  // ---------- Estilo de botones ----------
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.caregiverPrimary,
      foregroundColor: Colors.white,

      elevation: 0,

      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),

      minimumSize: const Size(double.infinity, 48),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
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
          selectedMedication = medications.first;
        }
      });

      // Si se está editando una rutina existente, carga sus datos
      if (widget.existingPrescription != null) {
        final sched = widget.existingPrescription!; // datos de la rutina existente
        prescriptionId = sched['id']; // guarda el id de la prescripción para futuras actualizaciones
        _dose.text = sched['dose'].toString(); // carga la dosis en el TextField
        _frequency.text = sched['frequencyHours']?.toString() ?? ''; // carga la frecuencia en el TextField, si existe
        _notes.text = sched['notes']?.toString() ?? ''; // carga las notas en el TextField, si existen
        selectedStatus = sched['status'] ?? 'ACTIVE'; // carga el estado, si existe, o deja 'ACTIVE' por defecto
        startDate = sched['startDate'] != null ? DateTime.parse(sched['startDate']) : null; // carga la fecha de inicio, si existe
        endDate = sched['endDate'] != null ? DateTime.parse(sched['endDate']) : null; // carga la fecha de fin, si existe
        
        
        // Cargar hora de primera dosis
        if (sched['firstDoseTime'] != null) {
          final parts = sched['firstDoseTime'].split(':');
          selectedHour = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        
        // busca el medicamento seleccionado en la lista de medicamentos cargados, comparando por id
        final medicationId = sched['medication']['id'];
        
        selectedMedication = medications.firstWhere(
          (m) => m.id == medicationId,
          orElse: () => medications.first,
        );
        
        // carga la unidad de dosis seleccionada, comparando por nombre (por ejemplo, 'MG', 'ML', etc.)
        final doseUnitStr = sched['doseUnit'] ?? 'MG';
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
  Future<void> _savePrescription() async {
    // si no se ha seleccionado un medicamento o una unidad de dosis, muestra un error
    if (selectedMedication == null || selectedDoseUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
      return;
    }

    // Formatear la hora seleccionada
    final hour = selectedHour != null
        ? '${selectedHour!.hour.toString().padLeft(2, '0')}:${selectedHour!.minute.toString().padLeft(2, '0')}'
        : null;

    final service = CaregiverPrescriptionService();

    try {
      final request = PrescriptionRequest(
        patientId: widget.patientId,
        medicationId: selectedMedication!.id,
        dose: double.parse(_dose.text),
        doseUnit: selectedDoseUnit!,
        frequencyHours: _frequency.text.isNotEmpty ? int.parse(_frequency.text) : null,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
        firstDoseTime: hour,
        notes: _notes.text.isNotEmpty ? _notes.text : null,
        status: selectedStatus,
      );

      if (prescriptionId != null) {
        await service.updatePrescription(
          prescriptionId: prescriptionId!,
          request: request,
        );
      } else {
        await service.createPrescription(request);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,

      appBar: AppLogoAppBar(
        title: widget.existingPrescription == null ? 'Nueva rutina' : 'Editar rutina',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: AppColors.caregiverCard,
            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingPrescription == null
                    ? 'Nueva prescripción'
                    : 'Editar prescripción',

                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.caregiverPrimary,
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Selector de medicamento ----------
              DropdownButtonFormField<MedicationResponse>(
                value: selectedMedication,
                decoration: _inputDecoration('Medicamento'),
                items: medications.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),

                onChanged: (value) => setState(() => selectedMedication = value),
              ),
              const SizedBox(height: 14),

              // ---------- Selector de unidad de dosis ----------
              DropdownButtonFormField<DoseUnit>(
                value: selectedDoseUnit,
                decoration: _inputDecoration('Unidad de dosis'),
                items: DoseUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                onChanged: (value) => setState(() => selectedDoseUnit = value),
              ),
              const SizedBox(height: 14),

              // ---------- Campo de dosis ----------
              TextField(
                controller: _dose,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Dosis'),
              ),
              const SizedBox(height: 14),

              // ---------- Campo de frecuencia ----------
              TextField(
                controller: _frequency,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Frecuencia (horas)'),
              ),
              const SizedBox(height: 14),
              // ---------- Selector de hora de primera dosis ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: _buttonStyle(),

                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());

                    if (picked != null) {
                      setState(() => selectedHour = picked);
                    }
                  },

                  child: Text(selectedHour == null ? 'Seleccionar primera dosis' : 'Primera dosis: ${selectedHour!.format(context)}'),
                ),
              ),

              const SizedBox(height: 14),

              // ---------- Selectores de fechas ----------
              // ---------- Fecha de inicio ----------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: _buttonStyle(),

                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                        }
                      },
                      child: Text(startDate == null ? 'Fecha inicio' : 'Inicio: ${startDate!.toIso8601String().split('T')[0]}'),
                    ),
                  ),

                  const SizedBox(width: 12),

              // ---------- Fecha de inicio ----------
                  Expanded(
                    child: ElevatedButton(
                      style: _buttonStyle(),

                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                      child: Text(endDate == null ? 'Fecha fin' : 'Fin: ${endDate!.toIso8601String().split('T')[0]}'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ---------- Campo de notas ----------
              TextField(
                controller: _notes,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Notas (opcional)',
                ).copyWith(hintText: 'Ej: Tomar con comida'),
              ),
              const SizedBox(height: 14),

              // ---------- Dropdown de estado ----------
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: _inputDecoration('Estado'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => setState(() => selectedStatus = value!),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiverAppBar,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: _savePrescription,
                  child: Text(widget.existingPrescription == null ? 'Crear prescripción' : 'Actualizar prescripción',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
