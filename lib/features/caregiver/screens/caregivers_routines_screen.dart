import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class CaregiversRoutinesScreen extends StatefulWidget {
  const CaregiversRoutinesScreen({super.key});

  @override
  State<CaregiversRoutinesScreen> createState() =>
      _CaregiversRoutinesScreenState();
}

class _CaregiversRoutinesScreenState extends State<CaregiversRoutinesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        title: const Text('Rutinas', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
