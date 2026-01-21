import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/screens/create_routine_screen.dart';
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
        appBar: AppBar(title: const Text('Detalle del paciente')),
        body: const Center(child: Text('Cargando paciente...')),
      );
    }

    // Cuando el paciente ya cargo, muestra los datos
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del paciente')),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Card(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // obtiene los datos guardados para mostrarlos
                children: [
                  Text(
                    patient!.username,
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: ${patient!.id}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Teléfono: ${patient!.phone}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.person, size: 80),
                  IconButton(
                    icon: const Icon(Icons.schedule),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateRoutineScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
