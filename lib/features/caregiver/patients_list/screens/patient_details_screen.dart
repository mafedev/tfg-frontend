import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/create_prescription_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patient_prescription/view_prescription_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/view_patient_routine.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_routine_service.dart';
import 'package:tfg_frontend/models/patient.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/patient_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  // Recibe el id del paciente
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  // Servicio encargado de obtener los datos del paciente desde el backend
  final PatientService _patientService = PatientService();

  // Contiene el paciente una vez se obtenga la respuesta
  // Es nullable porque al inicio aún no se ha cargado la información
  Patient? patient;

  // Servicio para obtener la rutina
  final RoutineService _routineService = RoutineService();

  // Para saber si el paciente tiene rutina creada
  bool loadingRoutine = true; // indica si se está cargando la rutina
  bool hasRoutine = false; // indica si el paciente tiene rutina creada

  // Para saber si el paciente tiene medicación asignada
  bool loadingMedication = true;
  bool hasMedication = false;

  // Cuando se inicia la pantalla, carga los datos del paciente
  @override
  void initState() {
    super.initState();
    _loadPatient();
    _checkRoutine(); // verifica si tiene rutina creada
    _checkMedication(); // verifica si tiene medicación asignada
  }

  // Obtiene los datos del paciente
  void _loadPatient() async {
    final result = await _patientService.getPatientDetails(widget.patientId);
    setState(() {
      patient = result; // guardamos lo que venga del backend
    });
  }

  // Verifica si el paciente tiene rutina creada
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

  // Verifica si el paciente tiene medicación asignada
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
    final phoneController = TextEditingController(text: patient!.phone); // guarda el texto que se introduce en el campo
    final notesController = TextEditingController(text: patient!.notes); // guardda las notas que se introduzcan para luego guardarlas en la base de datos
    String? diseaseStage = patient!.diseaseStage;

    // Muestra un diálogo para editar los datos del paciente
    // es await porque queremos esperar a que el usuario termine de editar antes de continuar con la ejecución del código
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar paciente'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Editar teléfono
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),

                // Agregar o editar notas
                TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notas')),

                // Dropdown para seleccionar la etapa de la enfermedad
                DropdownButton<String>(
                  value: diseaseStage,
                  hint: const Text('Etapa de la enfermedad'),
                  items: ['EARLY', 'MODERATE', 'ADVANCED']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => diseaseStage = value),
                ),
              ],
            ),
          ),
          actions: [
            // Al presionar cancelar, simplemente cierra el diálogo sin guardar cambios
            TextButton(onPressed: () => Navigator.pop(context),child: const Text('Cancelar')),

            // Al presionar guardar, llama a la función _updatePatient que hace la llamada al servicio para actualizar los datos del paciente en el backend
            ElevatedButton(
              onPressed: () async {
                await _updatePatient(
                  phoneController.text,
                  notesController.text,
                  diseaseStage,
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ------------------- Llamada al servicio para actualizar -------------------
  Future<void> _updatePatient(String phone, String notes, String? diseaseStage) async {
    
    // Hace la llamada al servicio para actualizar los datos del paciente en el backend
    final success = await _patientService.updatePatient(
      id: patient!.id,
      phone: phone,
      notes: notes,
      diseaseStage: diseaseStage,
    );

    // si sale bien, actualiza los datos
    if (success) {
      setState(() {
        patient = Patient(
          id: patient!.id,
          username: patient!.username,
          phone: phone,
          notes: notes,
          diseaseStage: diseaseStage,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar paciente')));
    }
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
                              patient!.username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 10),
                            Text(
                              'ID: ${patient!.id}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const Icon(Icons.person, size: 80),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // ---------- Información del paciente ----------
                    // Teléfono
                    Text('Teléfono: ${patient!.phone ?? "No especificado"}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),

                    // Etapa de la enfermedad
                    Text('Etapa de la enfermedad: ${patient!.diseaseStage ?? "No especificada"}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    
                    // Notas
                    Text('Notas: ${patient!.notes ?? "Sin notas"}', style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 20),

                    // ---------- Botón para editar paciente ----------
                    SizedBox(
                      width: double.infinity, // el botón ocupa todo el ancho disponible
                      // Al presionar, se llama a la función _editPatient que muestra un diálogo para editar los datos del paciente
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar paciente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caregiverAppBar,
                        ),
                        onPressed: _editPatient,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- Botón para crear o ver rutina ----------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: loadingRoutine
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            // Si tiene rutina, muestra el ícono de ver rutina, si no, el de crear rutina
                            : Icon(hasRoutine ? Icons.visibility : Icons.schedule, color: Colors.white),
                        // Si tiene rutina, muestra "Ver rutina", si no, "Crear rutina"
                        label: Text(hasRoutine ? 'Ver rutina' : 'Crear rutina', style: const TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverAppBar,),
                        // Si está cargando, deshabilita el botón
                        onPressed: loadingRoutine
                            ? null
                            : () { // al presionar, navega a la pantalla correspondiente
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => hasRoutine // si tiene rutina
                                        ? ViewRoutineScreen(patientId: patient!.id) // muestra la rutina
                                        : CreateRoutineScreen(patientId: patient!.id,isEdit: false), // si no, permite crearla
                                  ),
                                );
                              },
                      ),
                    ),

                    const SizedBox(width: 20,),

                    // ---------- Botón rutina de medicamentos ----------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        // Si tiene medicación, muestra el ícono de ver medicación, si no, el de agregar medicación
                        icon: loadingMedication
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(hasMedication ? Icons.visibility : Icons.medication, color: Colors.white),
                        label: Text(hasMedication ? 'Ver prescripción' : 'Crear prescripción',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        
                        // Si está cargando, deshabilita el botón
                        onPressed: loadingMedication
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => hasMedication
                                        ? ViewPrescriptionScreen(patientId: patient!.id) // si tiene medicación asignada, navega a verlas
                                        : CreatePrescriptionScreen(patientId: patient!.id), // si no, navega a crear nueva medicación
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
