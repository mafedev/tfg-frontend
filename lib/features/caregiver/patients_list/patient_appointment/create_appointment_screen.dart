import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_appointment_service.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final int patientId;
  final Map<String, dynamic>? existingAppointment;

  const CreateAppointmentScreen({super.key, required this.patientId, this.existingAppointment});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateTimeController = TextEditingController();

  final service = AppointmentService();

  bool isEditing = false;
  int? appointmentId;

  @override
  void initState() {
    super.initState();

    if (widget.existingAppointment != null) {
      final appt = widget.existingAppointment!;

      isEditing = true;
      appointmentId = appt['id'];

      titleController.text = appt['title'] ?? '';
      descriptionController.text = appt['description'] ?? '';
      locationController.text = appt['location'] ?? '';
      dateTimeController.text = appt['dateTime'] ?? '';
    }
  }

  void saveAppointment() async {
    bool success;

    if (isEditing) {
      success = await service.updateAppointment(
        id: appointmentId!,
        title: titleController.text,
        description: descriptionController.text,
        location: locationController.text,
        dateTime: dateTimeController.text,
      );
    } else {
      success = await service.createAppointment(
        title: titleController.text,
        description: descriptionController.text,
        location: locationController.text,
        dateTime: dateTimeController.text,
        patientId: widget.patientId,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Cita creada" : "Error al crear cita")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar cita" : "Crear cita")),
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
              onPressed: saveAppointment,
              child: Text(isEditing ? "Actualizar" : "Crear"),
            ),
          ],
        ),
      ),
    );
  }
}
