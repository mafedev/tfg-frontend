import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_request.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final int patientId; // id del paciente
  final AppointmentResponse? existingAppointment; // es para poder usar la screen para editar la cita

  const CreateAppointmentScreen({super.key, required this.patientId, this.existingAppointment});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  // ---------- Controladores ----------
  final titleController = TextEditingController(); // controlador para el título
  final descriptionController = TextEditingController(); // controlador para la descripción
  final locationController = TextEditingController();
  final dateTimeController = TextEditingController();

  final service = AppointmentService();

  bool isEditing = false; // indica si se está editando una cita existente o creando una nueva
  int? appointmentId; // id de la cita que se está editando
  DateTime? selectedDateTime; // fecha y hora seleccionada para la cita, se usa para mostrarla en el TextField y para enviarla al backend

  @override
  void initState() {
    super.initState();

    // si se está editando una cita
    if (widget.existingAppointment != null) {
      final appt = widget.existingAppointment!; // guarda la cita no nula
      isEditing = true; // indica que se está editando
      appointmentId = appt.id; // se obtiene id de la cita para luego poder actualizarla

      // Se obtiene la inforamción para luego mostrarla en los TextField
      titleController.text = appt.title;
      descriptionController.text = appt.description;
      locationController.text = appt.location;
      selectedDateTime = appt.dateTime;

      final dt = selectedDateTime!;
      // formatea la fecha agregando un 0 a la izquierda, 02/02/2026
      dateTimeController.text =
          "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    }
  }

  // ---------- Seleccionar fecha y hora ----------
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2020), // fecha mínima
      lastDate: DateTime(2100), // fecha máxima
    );

    if (date == null) {
      return;
    }

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

  // ---------- Guardar cita ----------
  void saveAppointment() async {
    bool success = false;

    final DateTime dateTime = selectedDateTime ?? DateTime.tryParse(dateTimeController.text) ?? DateTime.now();

    final request = AppointmentRequest(
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      dateTime: dateTime,
      patientId: widget.patientId,
    );

    try {
      if (isEditing) {
        await service.updateAppointment(id: appointmentId!, request: request);
      } else {
        await service.createAppointment(request);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cita guardada")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al guardar cita")));
    }
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
