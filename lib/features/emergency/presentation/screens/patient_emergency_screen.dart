import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class PatientEmergencyScreen extends StatelessWidget {
  const PatientEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Emergencia', backgroundColor: AppColors.patientAppBar,
      ),
    );
  }
}
