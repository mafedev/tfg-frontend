import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/relation/relation_service.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController codeController = TextEditingController();
  final RelationService _relationService = RelationService();

  Future<void> _link() async {
    final code = await _relationService.linkPatient(codeController.text.trim());

    if (code != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PAciente conectado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error conectando el paciente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio del Paciente")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código del cuidador',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _link, child: const Text('Vincular')),
          ],
        ),
      ),
    );
  }
}
