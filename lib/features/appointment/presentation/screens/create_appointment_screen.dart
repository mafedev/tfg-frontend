import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_request.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.caregiverSecondary,
          width: 1.2,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.caregiverPrimary,
          width: 2,
        ),
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
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
      backgroundColor: AppColors.caregiverBackground,
      appBar: AppLogoAppBar(title: isEditing ? "Editar cita" : "Crear cita", backgroundColor: AppColors.caregiverAppBar),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: AppColors.caregiverCard,
            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? "Editar cita" : "Nueva cita",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.caregiverPrimary,
                ),
              ),

              const SizedBox(height: 18),

              // ---------- Nombre ----------
              TextField(
                controller: titleController,
                decoration: _inputDecoration("Título"),
              ),

              const SizedBox(height: 12),

              // ---------- Descripción ----------
              TextField(
                controller: descriptionController,
                decoration: _inputDecoration("Descripción"),
              ),

              const SizedBox(height: 12),

              // ---------- Lugar ----------
              TextField(
                controller: locationController,
                decoration: _inputDecoration("Lugar"),
              ),

              const SizedBox(height: 12),

              // ---------- Fecha ----------
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.caregiverSecondary,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.caregiverPrimary,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              selectedDateTime == null
                                  ? 'Fecha'
                                  : '${selectedDateTime!.day.toString().padLeft(2, '0')}/'
                                        '${selectedDateTime!.month.toString().padLeft(2, '0')}/'
                                        '${selectedDateTime!.year}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: InkWell(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.caregiverSecondary,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.caregiverPrimary,
                            ),

                            const SizedBox(height: 6),

                            Text(
                              selectedDateTime == null
                                  ? 'Hora'
                                  : '${selectedDateTime!.hour.toString().padLeft(2, '0')}:'
                                        '${selectedDateTime!.minute.toString().padLeft(2, '0')}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ---------- Botón crear ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiverPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: saveAppointment,
                  child: Text(
                    isEditing ? "Actualizar cita" : "Crear cita",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
