import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_medication/create_medication_schedule_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_medication/view_medication_schedule_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_routine/view_patient_routine.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_prescription_service.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_routine_service.dart';
import 'package:tfg_frontend/features/relation/models/patient.dart';
import 'package:tfg_frontend/features/patient/services/patient_service.dart';

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

  @override
  Widget build(BuildContext context) {
    // Si patient es null, mostramos un mensaje de carga
    if (patient == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppLogoAppBar(title: 'Detalle del paciente', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(child: Text('Cargando paciente...')),
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
                    Row(
                      children: [
                        // ---------- Teléfono ----------
                        const Icon(Icons.phone,size: 20, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text('${patient!.phone}', style: const TextStyle(fontSize: 16),),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------- Botón para crear rutina ----------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(

                        // Si tiene rutina, muestra el ícono de ver rutina, si no, el de crear rutina
                        icon: Icon(hasRoutine ? Icons.visibility : Icons.schedule, color: Colors.white),

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
                        icon: Icon(hasMedication ? Icons.visibility : Icons.medication,color: Colors.white),

                        // Lo mismo, pero con el texto
                        label: Text(hasMedication ? 'Ver medicación': 'Agregar medicación',
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
                                        ? ViewMedicationScheduleScreen(patientId: patient!.id) // si tiene medicación asignada, navega a verlas
                                        : CreateMedicationScheduleScreen(patientId: patient!.id), // si no, navega a crear nueva medicación
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
