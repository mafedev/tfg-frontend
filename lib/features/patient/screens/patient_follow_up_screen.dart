import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';

class PatientFollowUpScreen extends StatefulWidget {
  const PatientFollowUpScreen({super.key});

  @override
  State<PatientFollowUpScreen> createState() => _PatientFollowUpScreenState();
}

class _PatientFollowUpScreenState extends State<PatientFollowUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppLogoAppBar(title: 'Seguimiento',backgroundColor: AppColors.patientMedium)
      );
  }
}
