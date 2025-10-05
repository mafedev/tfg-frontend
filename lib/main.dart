import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';
import 'package:tfg_frontend/features/auth/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: LoginScreen(),
      ),
    );
  }
}
