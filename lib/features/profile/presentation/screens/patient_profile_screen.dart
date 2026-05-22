import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/profile/data/profile_service.dart';
import 'package:tfg_frontend/features/relation/data/relation_service.dart';
import 'package:tfg_frontend/shared/dtos/relation/caregiver_contact.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:tfg_frontend/shared/widgets/emergency_call_fab.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final RelationService _relationService = RelationService();

  Map<String, dynamic>? profile;
  List<CaregiverContact> caregivers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileData = await _profileService.getMyProfile();
      final caregiverData = await _relationService.getMyCaregivers();

      if (!mounted) return;

      setState(() {
        profile = profileData;
        caregivers = caregiverData;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      AppSnackBar.showError(context, 'No se pudo cargar la información');
    }
  }

  String _textOrDefault(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No disponible';
    }
    return value.trim();
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.patientCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _caregiverCard(CaregiverContact caregiver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.patientCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _textOrDefault(caregiver.username),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 18,
                color: AppColors.patientPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _textOrDefault(caregiver.phone),
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.patientBackground,
      appBar: const AppLogoAppBar(
        title: 'Perfil',
        backgroundColor: AppColors.patientAppBar,
      ),
      floatingActionButton: const EmergencyCallFAB(),
      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Datos del paciente',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                _infoCard(
                  'Nombre',
                  _textOrDefault(
                    profile?['username'] as String? ??
                        profile?['name'] as String?,
                  ),
                ),

                _infoCard(
                  'Teléfono',
                  _textOrDefault(profile?['phone'] as String?),
                ),

                _infoCard(
                  'Correo',
                  _textOrDefault(profile?['email'] as String?),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Cuidadores vinculados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 14),

                if (caregivers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.patientCard,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No hay cuidadores vinculados todavía.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),

                if (caregivers.isNotEmpty)
                  ...caregivers.map((c) => _caregiverCard(c)),

                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }
}
