import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/home/patient_home_screen.dart';
import 'package:tfg_frontend/features/home/caregiver_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenido")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "¿Eres paciente o cuidador?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientHomeScreen(),
                    ),
                  );
                },
                child: const Text("Soy paciente"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaregiverHomeScreen(),
                    ),
                  );
                },
                child: const Text("Soy cuidador"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
