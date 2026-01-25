import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';

class CaregiverFollowUpScreen extends StatefulWidget {
  const CaregiverFollowUpScreen({super.key});

  @override
  State<CaregiverFollowUpScreen> createState() =>
      _CaregiverFollowUpScreenState();
}

class _CaregiverFollowUpScreenState extends State<CaregiverFollowUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Seguimiento', backgroundColor: AppColors.caregiverMedium),
    );
  }
}
