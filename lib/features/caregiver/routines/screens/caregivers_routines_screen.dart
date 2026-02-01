import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';

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
      appBar: const AppLogoAppBar(title: 'Rutinas', backgroundColor: AppColors.caregiverAppBar),
    );
  }
}
