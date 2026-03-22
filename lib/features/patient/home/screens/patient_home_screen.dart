import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/services/relation_service.dart';

// Esta pantalla es para el paciente. Permite vincularse con un cuidador usando el código de vinculación
class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // Controlador para el campo de texto donde el paciente escribe el código
  final TextEditingController codeController = TextEditingController();
  
  // Servicio para manejar la relación entre paciente y cuidador
  final RelationService _relationService = RelationService();

  // Función que se ejecuta cuando el paciente presiona el botón de vincular
  Future<void> _link() async {
  final success = await _relationService.linkPatient(codeController.text.trim());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(success
          ? 'Paciente conectado correctamente'
          : 'Error conectando el paciente'),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título
      appBar: const AppLogoAppBar(title: 'Inicio', backgroundColor: AppColors.patientAppBar),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Campo de texto para escribir el código de vinculación
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de vinculación',
                ),
              ),
              const SizedBox(height: 16), // Espacio entre el campo y el botón
              // Botón para vincular
              ElevatedButton(onPressed: _link, child: const Text('Vincular')),
            ],
          ),
        ),
      ),
    );
  }
}
