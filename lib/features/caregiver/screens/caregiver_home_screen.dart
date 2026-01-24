import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

// Home del cuidador
class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

// Estado de la pantalla principal del cuidador
class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        title: Text('Inicio', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hola, nombre!', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30
            )),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columnas
                mainAxisSpacing: 16, // espacio horizontal
                crossAxisSpacing: 16, // espacio vertical
                children: List.generate(4, (index) { // crea una lista de 4 elementos
                  return Container( // cada elemento es un contenedor
                    color: Colors.white,
                    child: const Center(
                      child: Placeholder()
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
