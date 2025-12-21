import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/relation/relation_service.dart';

class CaregiverPatientsScreen extends StatefulWidget {
  const CaregiverPatientsScreen({super.key});

  @override
  State<CaregiverPatientsScreen> createState() =>
      _CaregiverPatientsScreenState();
}

class _CaregiverPatientsScreenState extends State<CaregiverPatientsScreen> {
  String? relationCode;
  final RelationService _relationService = RelationService();

  // Espera que el backend devuelva el código
  void _generateCode() async {
    final code = await _relationService.generateRelationCode();

    setState(() {
      relationCode = code;
    });

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el código')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _generateCode,
              child: const Text('Agregar paciente'),
            ),
            const SizedBox(height: 20),
            if (relationCode != null)
              Text('Código generado: $relationCode'),
          ],
        ),
      ),
    );
  }
}
