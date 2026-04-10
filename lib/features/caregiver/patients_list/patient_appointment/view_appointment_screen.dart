import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_appointment_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(
        title: 'Citas',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? const Center(child: Text("No hay citas"))
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final a = appointments[index];

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
                        Text("Fecha: ${a['dateTime'] ?? ''}"),
                        Text("Descripción: ${a['description'] ?? ''}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {_deleteAppointment(a['id']);},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
