import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        title: const Text('Seguimiento', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
