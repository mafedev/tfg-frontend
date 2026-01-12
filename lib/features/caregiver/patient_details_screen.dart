import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/relation/patient_service.dart';
import 'package:tfg_frontend/features/relation/relation_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final PatientService _patientService = PatientService();

  Map<String, dynamic>? patient;

  @override
  void initState(){
    super.initState();
    _loadPatient();
  }

  void _loadPatient() async {
    final result = await _patientService.getPatientDetails(widget.patientId);
    setState(() {
      patient = result; // guardamos lo que venga del backend
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si patient es null, mostramos un texto simple
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del paciente')),
        body: const Center(child: Text('Cargando paciente...')),
      );
    }

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
                children: [
                  Text(
                    '${patient!['username']}',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: ${patient!['id']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Teléfono: ${patient!['phone']}',
                      style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.person, size: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}