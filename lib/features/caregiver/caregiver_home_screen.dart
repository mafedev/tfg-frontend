import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';
import 'service/rutine_service.dart';

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
      appBar: AppBar(title: Text('Home Cuidador')),
      body: Container(
        color: AppColors.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hola, nombre!', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30
            )),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2 columnas
                mainAxisSpacing: 16, // espacio horizontal
                crossAxisSpacing: 16, // espacio vertical
                children: List.generate(4, (index) { // crea una lista de 4 elementos
                  return Container( // cada elemento es un contenedor
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'Placeholder',
                      ),
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

Widget _buildGridItem(String text) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.center,
    child: Text(text, style: const TextStyle(fontSize: 18)),
  );
}
