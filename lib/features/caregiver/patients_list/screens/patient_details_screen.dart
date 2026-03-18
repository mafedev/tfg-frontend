import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/patient_service.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/create_prescription_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/view_prescription_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/view_patient_routine.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_routine_service.dart';
import 'package:tfg_frontend/models/patient.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  // Recibe el id del paciente
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  // Contiene el paciente una vez se obtenga la respuesta
  // Es nullable porque al inicio aún no se ha cargado la información
  Patient? patient;

  // Para saber si el paciente tiene rutina creada
  bool loadingRoutine = true; // indica si se está cargando la rutina
  bool hasRoutine = false; // indica si el paciente tiene rutina creada

  // Para saber si el paciente tiene medicación asignada
  bool loadingMedication = true;
  bool hasMedication = false;

  bool updatingPatient = false;
  
  // Servicio encargado de obtener los datos del paciente desde el backend
  final PatientService _patientService = PatientService();
  // Servicio para obtener la rutina
  final RoutineService _routineService = RoutineService();

  @override
  void initState() {
    super.initState();
    _loadPatient();
    _checkRoutine(); // verifica si tiene rutina creada
    _checkMedication(); // verifica si tiene medicación asignada
  }

  // ---------- Cargar paciente ----------
  void _loadPatient() async {
    final result = await _patientService.getPatientDetails(widget.patientId);
    setState(() {
      patient = result; // guardamos lo que venga del backend
    });
  }

  // ---------- Cargar rutina ----------
  void _checkRoutine() async {
    try {
      final routine = await _routineService.getRoutine(widget.patientId); // intenta obtener la rutina con el id del paciente
      setState(() {
        hasRoutine = routine != null; // si la rutina no es nula, entonces tiene rutina
        loadingRoutine = false; // ya no está cargando
      });
    } catch (e) {
      setState(() => loadingRoutine = false); // en caso de error, solo indica que ya no está cargando
    }
  }

  // ---------- Cargar medicación ----------
  void _checkMedication() async {
    try {
      final meds = await CaregiverPrescriptionService().getByPatient(widget.patientId); // obtiene la medicación del paciente con su id

      // si la lista no está vacía, entonces tiene medicación asignada
      setState(() {
        hasMedication = meds.isNotEmpty; // si la lista no está vacía, entonces tiene medicación asignada
        loadingMedication = false; // ya no está cargando
      });
    } catch (e) {
      setState(() => loadingMedication = false);
    }
  }

  // ------------------- Editar paciente -------------------
  void _editPatient() async {
    if (patient == null) return;

    final phoneController = TextEditingController(text: patient!.phone);
    final notesController = TextEditingController(text: patient!.notes);
    String? diseaseStage = patient!.diseaseStage;

    final _formKey = GlobalKey<FormState>();

    // Muestra un diálogo para editar los datos del paciente
    // es await porque queremos esperar a que el usuario termine de editar antes de continuar con la ejecución del código
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar paciente'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es obligatorio';
                      }
                      if (value.length < 9) {
                        return 'Número de teléfono no válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: diseaseStage,
                    decoration: const InputDecoration(
                      labelText: 'Etapa de la enfermedad',
                      prefixIcon: Icon(Icons.face),
                      border: OutlineInputBorder(),
                    ),
                    items: ['EARLY', 'MODERATE', 'ADVANCED']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        diseaseStage = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Al presionar cancelar, simplemente cierra el diálogo sin guardar cambios
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: updatingPatient
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setDialogState(() => updatingPatient = true);
                      await _updatePatient(
                        phoneController.text,
                        notesController.text,
                        diseaseStage,
                      );
                      setDialogState(() => updatingPatient = false);
                      Navigator.pop(context);
                    },
              child: updatingPatient
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------- Llamada al servicio para actualizar -------------------
  Future<void> _updatePatient(String phone, String notes, String? diseaseStage) async {
    final token = await SecureStorageService().getToken();
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/api/patients/${patient!.id}'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({
        'phone': phone,
        'notes': notes,
        'diseaseStage': diseaseStage,
      }),
    );

    // si sale bien, actualiza los datos
    if (response.statusCode == 200) {
      setState(() {
        patient = Patient(
          id: patient!.id,
          name: patient!.name,
          phone: phone,
          notes: notes,
          diseaseStage: diseaseStage,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar paciente')));
    }
  }

  String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

  @override
  Widget build(BuildContext context) {
    // Si patient es null, mostramos un mensaje de carga
    if (patient == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppLogoAppBar(title: 'Detalle del paciente', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    // Cuando el paciente ya cargo, muestra los datos
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Detalle del paciente', backgroundColor: AppColors.caregiverAppBar),

      // SingleChildScrollView para que se pueda scrollear en pantallas pequeñas
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---------- Nombre e id ----------
                    // obtiene los datos guardados para mostrarlos
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalize(patient!.name),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('ID: ${patient!.id}', style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const Icon(Icons.person, size: 80),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // ---------- Información del paciente ----------
                    _infoText('Teléfono', patient!.phone),
                    _infoText('Estado de la enfermedad', patient!.diseaseStage),
                    _infoText('Notas', patient!.notes),
                    const SizedBox(height: 20),

                    // ---------- Botón para editar paciente ----------
                    SizedBox(
                      width: double.infinity, // el botón ocupa todo el ancho disponible
                      // Al presionar, se llama a la función _editPatient que muestra un diálogo para editar los datos del paciente
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Editar paciente', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverAppBar),
                        onPressed: _editPatient,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- Botón para crear o ver rutina ----------
                    _routineButton(),

                    const SizedBox(height: 20),

                    // ---------- Botón prescripción ----------
                    _medicationButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Widgets modularizados ----------
 Widget _infoText(String label, String? value) {
  final displayValue =
      (value == null || value.trim().isEmpty) ? "No especificado" : value;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: displayValue),
        ],
      ),
    ),
  );
}

  Widget _routineButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: loadingRoutine
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(hasRoutine ? Icons.visibility : Icons.schedule, color: Colors.white),
        label: Text(hasRoutine ? 'Ver rutina' : 'Crear rutina', style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverAppBar),
        onPressed: loadingRoutine
            ? null
            : () async {
                setState(() => loadingRoutine = true);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => hasRoutine
                        ? ViewRoutineScreen(patientId: patient!.id)
                        : CreateRoutineScreen(patientId: patient!.id, isEdit: false),
                  ),
                );
                setState(() => loadingRoutine = false);
              },
      ),
    );
  }

  Widget _medicationButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: loadingMedication
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(hasMedication ? Icons.visibility : Icons.medication, color: Colors.white),
        label: Text(hasMedication ? 'Ver prescripción' : 'Crear prescripción', style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        onPressed: loadingMedication
            ? null
            : () async {
                setState(() => loadingMedication = true);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => hasMedication
                        ? ViewPrescriptionScreen(patientId: patient!.id)
                        : CreatePrescriptionScreen(patientId: patient!.id),
                  ),
                );
                setState(() => loadingMedication = false);
              },
      ),
    );
  }
}