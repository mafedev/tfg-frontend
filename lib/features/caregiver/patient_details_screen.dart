import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/relation/models/patient.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
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
                    '${patient.username}',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID: ${patient.id}',
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
