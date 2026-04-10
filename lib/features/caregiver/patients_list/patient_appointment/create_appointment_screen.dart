import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_appointment_service.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final int patientId;

  const CreateAppointmentScreen({super.key, required this.patientId});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateTimeController = TextEditingController();

  final service = AppointmentService();

  void createAppointment() async {
    final success = await service.createAppointment(
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      dateTime: dateTimeController.text,
      patientId: widget.patientId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Cita creada" : "Error al crear cita")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear cita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Título"),
            ),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Lugar"),
            ),

            TextField(
              controller: dateTimeController,
              decoration: const InputDecoration(
                labelText: "Fecha (2026-04-15T10:30:00)",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: createAppointment,
              child: const Text("Crear cita"),
            ),
          ],
        ),
      ),
    );
  }
}
