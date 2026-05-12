import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool isPatient;

  const AppFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.isPatient = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isPatient
        ? AppColors.patientPrimary
        : AppColors.caregiverPrimary;

    final Color background = isPatient
        ? AppColors.patientAccentGreen
        : AppColors.caregiverAccent;

    if (label != null && label!.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: background,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label!,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 4,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: background,
      child: Icon(icon, color: Colors.white),
    );
  }
}