import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/home/data/caregiver_home_service.dart';
import 'package:tfg_frontend/features/home/presentation/widgets/appointment_calendar_widget.dart';
import 'package:tfg_frontend/features/home/presentation/widgets/next_medications_widget.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

// Estado de la pantalla principal del cuidador
class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final CaregiverHomeService _service = CaregiverHomeService();
  final SecureStorageService _storage = SecureStorageService();
  final PageController _pageController = PageController(viewportFraction: .86);

  bool loading = true;
  String caregiverName = 'cuidador';
  List<dynamic> prescriptions = [];
  List<DateTime> appointmentDays = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final username = await _storage.getUsername();
      final prescriptionData = await _service.getHomePrescriptions();
      final calendarData = await _service.getCalendarDays();

      setState(() {
        caregiverName = username?.isNotEmpty == true ? username! : 'cuidador';
        prescriptions = prescriptionData;
        appointmentDays = calendarData;
        loading = false;
      });

    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _loadAppointmentsByDay(DateTime date) async {
    try {
      final data = await _service.getAppointmentsByDate(date);

      _showAppointmentsBottomSheet(date, data);
    } catch (e) {
      debugPrint("Error loading appointments: $e");
    }
  }

  void _showAppointmentsBottomSheet(DateTime date, List<dynamic> appointments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final a = appointments[index];

                      return ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(a['title'] ?? 'Cita'),
                        subtitle: Text(
                          "${a['patientName']} • ${(a['dateTime'])}",
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Inicio', backgroundColor: AppColors.caregiverAppBar),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $caregiverName',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Revisa tus tareas del día y mantén todo bajo control.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoCard('Tomas pendientes', prescriptions.length.toString()),
                    _infoCard('Días con citas', appointmentDays.length.toString()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
            const SizedBox(height: 24),

            const Text(
              'Próximas medicaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Desliza para ver las próximas tomas programadas',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 15),

            NextMedicationsWidget(
              prescriptions: prescriptions,
              pageController: _pageController,
            ),

            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),
            const SizedBox(height: 24),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calendario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toca un día para ver citas',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 15),

            AppointmentCalendarWidget(
              appointmentDays: appointmentDays,
              onDaySelected: _loadAppointmentsByDay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
