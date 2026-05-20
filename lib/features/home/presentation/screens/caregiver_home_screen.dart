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
        final rawName = username?.trim() ?? '';
        caregiverName = rawName.isNotEmpty ? _capitalize(rawName) : 'Cuidador';
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

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
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
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.caregiverPrimary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "${date.day}/${date.month}/${date.year}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '${appointments.length} cita${appointments.length == 1 ? '' : 's'} programada${appointments.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.caregiverPrimary.withOpacity(0.75),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final a = appointments[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.caregiverPrimary.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.caregiverPrimary.withOpacity(
                                    0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.event,
                                  color: AppColors.caregiverPrimary,
                                ),
                              ),
                              title: Text(
                                a['title'] ?? 'Cita',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "${a['patientName']} • ${a['dateTime']}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        appBar: const AppLogoAppBar(title: 'Inicio', backgroundColor: AppColors.caregiverAppBar),
        backgroundColor: AppColors.caregiverBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Inicio', backgroundColor: AppColors.caregiverAppBar),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),

            const SizedBox(height: 25),

            const Divider(),
            const SizedBox(height: 25),
            _sectionDivider("Próximas medicaciones"),

            const SizedBox(height: 10),

            NextMedicationsWidget(
              prescriptions: prescriptions,
              pageController: _pageController,
            ),

            const SizedBox(height: 25),

            const Divider(),
            const SizedBox(height: 25),

            _sectionDivider("Calendario"),

            const SizedBox(height: 10),

            Container(
              decoration: _cardDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: AppointmentCalendarWidget(
                  appointmentDays: appointmentDays,
                  onDaySelected: _loadAppointmentsByDay,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.caregiverPrimary, AppColors.caregiverSecondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.caregiverPrimary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $caregiverName!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Revisa tus tareas del día y mantén todo bajo control',
            style: TextStyle(fontSize: 15, color: Colors.white70),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _statCard('Tomas', prescriptions.length.toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard('Citas', appointmentDays.length.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.caregiverPrimary,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.caregiverPrimary,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.caregiverCard,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.caregiverPrimary.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: AppColors.caregiverPrimary.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
