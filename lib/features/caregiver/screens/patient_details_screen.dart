import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/screens/routine/create_routine_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  // Obtiene los datos del paciente
  void _loadPatient() async {
    final result = await _patientService.getPatientDetails(widget.patientId);
    setState(() {
      patient = result; // guardamos lo que venga del backend
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si patient es null, mostramos un mensaje de carga
    if (patient == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.caregiverMedium,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Detalle del paciente',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: Text('Cargando paciente...')),
      );
    }

    // Cuando el paciente ya cargo, muestra los datos
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detalle del paciente',style: TextStyle(color: Colors.white),
        ),
      ),

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
                                style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w700),
                              ),

                              const SizedBox(height: 10),
                              Text(
                                'ID: ${patient!.id}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                      const Icon(Icons.person, size: 80),                      ],
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
                      width: double.infinity, // El botón ocupa todo el ancho disponible
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: const Text('Crear rutina'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.caregiverMedium,
                        ),
                        // Cuando se presiona, navega a la pantalla de creación de rutina
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateRoutineScreen(patientId: patient!.id),
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
