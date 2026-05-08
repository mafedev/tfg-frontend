import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_request.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final int patientId;
  final AppointmentResponse? existingAppointment;

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

  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.existingAppointment != null) {
      final appt = widget.existingAppointment!;

      isEditing = true;
      appointmentId = appt.id;

      titleController.text = appt.title;
      descriptionController.text = appt.description;
      locationController.text = appt.location;

      selectedDateTime = appt.dateTime;
      final dt = selectedDateTime!;
      dateTimeController.text =
          "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime ?? DateTime.now(),
      ),
    );

    if (time == null) return;

    final finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      selectedDateTime = finalDateTime;

      dateTimeController.text =
          "${finalDateTime.day.toString().padLeft(2, '0')}/"
          "${finalDateTime.month.toString().padLeft(2, '0')}/"
          "${finalDateTime.year} "
          "${finalDateTime.hour.toString().padLeft(2, '0')}:"
          "${finalDateTime.minute.toString().padLeft(2, '0')}";
    });
  }


  void saveAppointment() async {
    bool success = false;

    final DateTime dateTime = selectedDateTime ??
        DateTime.tryParse(dateTimeController.text) ??
        DateTime.now();

    final request = AppointmentRequest(
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      dateTime: dateTime,
      patientId: widget.patientId,
    );

    if (isEditing) {
      success = await service.updateAppointment(
        id: appointmentId!,
        request: request,
      );
    } else {
      success = await service.createAppointment(request);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Cita guardada" : "Error al guardar cita")),
    );
    Navigator.pop(context);
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
              readOnly: true,
              onTap: _pickDateTime,
              decoration: const InputDecoration(
                labelText: "Fecha y hora",
                suffixIcon: Icon(Icons.calendar_today),
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
