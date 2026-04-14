import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_appointment_service.dart';
import 'create_appointment_screen.dart';

class ViewAppointmentsScreen extends StatefulWidget {
  final int patientId;

  const ViewAppointmentsScreen({super.key, required this.patientId});

  @override
  State<ViewAppointmentsScreen> createState() => _ViewAppointmentsScreenState();
}

class _ViewAppointmentsScreenState extends State<ViewAppointmentsScreen> {
  bool loading = true;
  List<dynamic> appointments = [];

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
        appointments.sort((a, b) {
          final dateA = DateTime.tryParse(a['dateTime'] ?? '');
          final dateB = DateTime.tryParse(b['dateTime'] ?? '');

          if (dateA == null || dateB == null) return 0;

          return dateA.compareTo(dateB);
        });

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
      ).showSnackBar(SnackBar(content: Text("Error eliminando cita: $e")));
    }
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

  List<dynamic> _filteredAppointments() {
    if (selectedDate == null) return appointments;

    return appointments.where((a) {
      final date = DateTime.tryParse(a['dateTime'] ?? '');
      if (date == null) return false;

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
                final a = filtered[index];

                DateTime? date;
                if (a['dateTime'] != null) {
                  date = DateTime.tryParse(a['dateTime']);
                }

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
                    title: Text(a['title'] ?? 'Sin título'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lugar: ${a['location'] ?? ''}"),

                        if (fecha.isNotEmpty)
                          Text("Día: $fecha"),

                        if (hora.isNotEmpty)
                          Text("Hora: $hora"),

                        Text("Descripción: ${a['description'] ?? ''}"),
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
                          _deleteAppointment(a['id']);
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
