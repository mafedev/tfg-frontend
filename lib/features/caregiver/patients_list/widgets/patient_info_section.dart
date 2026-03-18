import 'package:flutter/material.dart';
import 'package:tfg_frontend/models/patient.dart';

class PatientInfoSection extends StatelessWidget {
  final Patient patient;

  const PatientInfoSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre e ID
        Row(
          children: [
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.username,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text('ID: ${patient.id}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const Icon(Icons.person, size: 80),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),

        // Teléfono
        Text('Teléfono: ${patient.phone ?? "No especificado"}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),

        // Etapa de la enfermedad
        Text(
          'Etapa de la enfermedad: ${patient.diseaseStage ?? "No especificada"}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Notas
        Text('Notas: ${patient.notes?.isNotEmpty == true ? patient.notes : "Sin notas"}',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}