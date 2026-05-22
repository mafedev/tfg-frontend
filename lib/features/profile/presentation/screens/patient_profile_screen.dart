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
    if (value == null) {
      return 'No disponible';
    }

    if (value.trim().isEmpty) {
      return 'No disponible';
    }
    return value.trim();
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.patientCard,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.patientPrimary.withOpacity(0.15),
            child: Icon(icon, size: 28, color: AppColors.patientPrimary),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _caregiverCard(CaregiverContact caregiver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.patientCard,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.patientPrimary,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textOrDefault(caregiver.username),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Perfil',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.patientBackground,
      appBar: const AppLogoAppBar(
        title: 'Perfil',
        backgroundColor: AppColors.patientAppBar,
      ),
      floatingActionButton: const EmergencyCallFAB(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.patientPrimary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 18),

            Center(
              child: Text(
                _textOrDefault(profile?['username'] ?? profile?['name']),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Información personal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            _infoCard(
              Icons.phone,
              'Teléfono',
              _textOrDefault(profile?['phone']),
            ),

            _infoCard(Icons.email, 'Correo', _textOrDefault(profile?['email'])),

            const SizedBox(height: 18),

            const Text(
              'Cuidadores',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            if (caregivers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.patientCard,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    'No hay cuidadores vinculados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

            if (caregivers.isNotEmpty)
              ...caregivers.map((c) => _caregiverCard(c)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
