import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class PatientAppoinmentScreen extends StatelessWidget {
  const PatientAppoinmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Citas', backgroundColor: AppColors.patientAppBar,
      ),
    );
  }
}
