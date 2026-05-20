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

            NextMedicationsWidget(prescriptions: prescriptions, pageController: _pageController),

            const SizedBox(height: 30),

            const Text(
              'Calendario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            AppointmentCalendarWidget(appointmentDays: appointmentDays),
          ],
        ),
      ),
    );
  }
}
