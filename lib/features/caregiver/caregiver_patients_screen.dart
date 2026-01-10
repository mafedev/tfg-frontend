import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/relation/models/patient.dart';
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

  List<Patient> patients = []; // lista de pacientes por cuidador

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
    } else {
      // Luego de generar el código, se actualiza la lista
      _loadPatients();
    }
  }

  // Obtiene la lista de pacientes
  void _loadPatients() async {
    final fetchedPatients = await _relationService.getPatients();

    setState(() {
      patients = fetchedPatients;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPatients(); // al abrir la pantalla, carga la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pacientes vinculados')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Ocupa todo el espacio disponible para la lista
            Expanded(
              child: ListView.separated(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(patient.username),
                    subtitle: Text('ID: ${patient.id}'),
                  );
                },
                separatorBuilder: (context, index) => const Divider(), // divide cada paciente
              ),
            ),
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
