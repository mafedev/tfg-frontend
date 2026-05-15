import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/appointment/data/caregiver_appointment_service.dart';
import 'package:tfg_frontend/features/appointment/presentation/screens/create_appointment_screen.dart';
import 'package:tfg_frontend/shared/dtos/appointment/appointment_response.dart';
import 'package:tfg_frontend/shared/enums/appointment/appointment_status.dart';
import 'package:tfg_frontend/shared/widgets/app_fab.dart';

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

  // ---------- Cargar citas ----------
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

  // ---------- Eliminar cita ----------
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

  // ---------- Actualizar estado ----------
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

  // ---------- Chip de estado ----------
  Widget _buildStatusChip(AppointmentResponse appointment, String value, String label) {
    final isSelected = appointment.status == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _updateStatus(appointment.id, value);
      },

      showCheckmark: false,
      selectedColor: AppColors.caregiverPrimary,
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.caregiverPrimary : Colors.grey.shade300,
        ),
      ),

      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  // ---------- Filtrar por fecha ----------
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

  // ---------- Lista filtrada ----------
  List<AppointmentResponse> _filteredAppointments() {
    if (selectedDate == null) {
      return appointments;
    }

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
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(
        title: 'Citas',
        backgroundColor: AppColors.caregiverAppBar,
      ),

      // ---------- FAB ----------
      floatingActionButton: AppFAB(
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
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.caregiverPrimary))
          : Column(
              children: [
                // ---------- Filtro ----------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedDate != null ? AppColors.caregiverPrimary : AppColors.caregiverSecondary,

                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      onPressed: selectedDate == null
                          ? _pickFilterDate
                          : () {setState(() => selectedDate = null);},

                      icon: Icon(
                        selectedDate == null
                            ? Icons.calendar_month
                            : Icons.close,
                      ),

                      label: Text(
                        selectedDate == null
                            ? 'Filtrar por fecha'
                            : 'Limpiar filtro (${selectedDate!.day.toString().padLeft(2, '0')}/'
                                  '${selectedDate!.month.toString().padLeft(2, '0')}/'
                                  '${selectedDate!.year})',

                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // ---------- Lista ----------
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text("No hay citas",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 100,
                          ),

                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final AppointmentResponse a = filtered[index];

                            final date = a.dateTime;

                            String fecha = '';
                            String hora = '';

                            fecha =
                                "${date.day.toString().padLeft(2, '0')}/"
                                "${date.month.toString().padLeft(2, '0')}/"
                                "${date.year}";

                            hora =
                                "${date.hour.toString().padLeft(2, '0')}:"
                                "${date.minute.toString().padLeft(2, '0')}";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          a.title,

                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.caregiverPrimary,
                                          ),
                                        ),
                                      ),

                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                        ),

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
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit,size: 18),
                                                SizedBox(width: 8),
                                                Text('Editar'),
                                              ],
                                            ),
                                          ),

                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, size: 18, color:AppColors.delete),
                                                SizedBox(width: 8),
                                                Text('Eliminar'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  // ---------- Fecha y hora ----------
                                  Row(
                                    children: [
                                      // Fecha
                                      const Icon(Icons.calendar_today, size: 18, color:AppColors.caregiverPrimary),
                                      const SizedBox(width: 8),

                                      Text(fecha, style: TextStyle(color:Colors.grey.shade800, fontWeight: FontWeight.w500)),
                                      const SizedBox(width: 18),

                                      // Hora
                                      const Icon(Icons.access_time, size: 18, color:AppColors.caregiverPrimary),
                                      const SizedBox(width: 8),

                                      Text(hora, style: TextStyle(color:Colors.grey.shade800, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // ---------- Lugar ----------
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 18, color:AppColors.caregiverPrimary),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(a.location,style: TextStyle(color:Colors.grey.shade700))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // ---------- Descripción ----------
                                  Text(a.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                                  const SizedBox(height: 16),

                                  // ---------- Estados ----------
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildStatusChip(a, 'PENDING', 'Pendiente'),
                                      _buildStatusChip(a, 'ATTENDED', 'Asistió'),
                                      _buildStatusChip(a, 'MISSED', 'No asistió'),
                                      _buildStatusChip(a, 'CANCELLED', 'Cancelada'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
