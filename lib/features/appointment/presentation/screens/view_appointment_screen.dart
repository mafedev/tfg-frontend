import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';
import 'package:tfg_frontend/shared/enums/appointment/appointment_status.dart';
import 'create_appointment_screen.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  final int patientId;

  const ViewAppointmentsScreen({super.key, required this.patientId});

  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  bool loading = true;
  List<AppointmentResponse> appointments = [];

  final service = AppointmentService();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final result = await service.getAppointmentsByPatient(widget.patientId);

      setState(() {
        appointments = result;
        appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error cargando citas: $e")));
    }
  }

  Future<void> _deleteAppointment(int id) async {
    try {
      await service.deleteAppointment(id);
      _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error eliminando cita")));
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final AppointmentStatus statusEnum = AppointmentStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => AppointmentStatus.PENDING,
      );

      await service.updateStatus(id: id, status: statusEnum);
      _loadAppointments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error actualizando estado")));
    }
  }

  Widget _buildStatusChip(AppointmentResponse appointment, String value, String label) {
    final isSelected = appointment.status == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _updateStatus(appointment.id, value);
      },
    );
  }

  Future<void> _pickFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<AppointmentResponse> _filteredAppointments() {
    if (selectedDate == null) return appointments;

    return appointments.where((a) {
      final date = a.dateTime;
      return date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAppointments();

    return Scaffold(
      appBar: const AppLogoAppBar(
        title: 'Citas',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickFilterDate,
                      ),
                      const SizedBox(width: 10),
                      if (selectedDate != null)
                        TextButton(
                          onPressed: () {
                            setState(() => selectedDate = null);
                          },
                          child: const Text("Limpiar"),
                        ),
                    ],
                  ),
                ),

        Expanded(
          child: filtered.isEmpty
          ? const Center(child: Text("No hay citas"))
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final AppointmentResponse a = filtered[index];

                final date = a.dateTime;

                String fecha = '';
                String hora = '';

                if (date != null) {
                  fecha =
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}";

                  hora =
                      "${date.hour.toString().padLeft(2, '0')}:"
                      "${date.minute.toString().padLeft(2, '0')}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(a.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lugar: ${a.location}"),

                        if (fecha.isNotEmpty) Text("Día: $fecha"),

                        if (hora.isNotEmpty) Text("Hora: $hora"),

                        Text("Descripción: ${a.description}"),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          children: [
                            _buildStatusChip(
                                a, 'PENDING', 'Pendiente'),
                            _buildStatusChip(
                                a, 'ATTENDED', 'Asistió'),
                            _buildStatusChip(
                                a, 'MISSED', 'No asistió'),
                            _buildStatusChip(
                                a, 'CANCELLED', 'Cancelada'),
                          ],
                        ),
                      ],
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateAppointmentScreen(
                                patientId: widget.patientId,
                                existingAppointment: a,
                              ),
                            ),
                          );

                          _loadAppointments();
                        }

                        
                        if (value == 'delete') {
                          _deleteAppointment(a.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.caregiverAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateAppointmentScreen(
                patientId: widget.patientId,
              ),
            ),
          );
          _loadAppointments();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
