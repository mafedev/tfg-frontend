import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class AppFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AppFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.caregiverPrimary,
      elevation: 3,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
