import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController(viewportFraction: .86);

  bool loading = true;
  List<dynamic> prescriptions = [];
  List<DateTime> appointmentDays = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prescriptionData = await _service.getHomePrescriptions();
      final calendarData = await _service.getCalendarDays();

      setState(() {
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
            const Text(
              'Hola',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            const Text(
              'Próximas medicaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            NextMedicationsWidget(
              prescriptions: prescriptions,
              pageController: _pageController,
            ),

            const SizedBox(height: 30),

            const Text(
              'Calendario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}
