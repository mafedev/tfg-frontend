import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/patient_details_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadPatients(); // al abrir la pantalla, carga la lista
  }

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

  // Elimina la relación con un paciente
  void _deletePatient(int patientId) async {
    bool deleted = await _relationService.deleteRelation(patientId);
    if (deleted) {
      // refresca la lista
      _loadPatients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente eliminado')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el paciente')),
        );
      }
    }
  }

  // Muestra un diálogo de confirmación antes de eliminar
  void _confirmDelete(int patientId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar paciente'),
        content: const Text('¿Está seguro de que quiere eliminar esta relación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deletePatient(patientId);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes vinculados'),
      ),
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
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () => _confirmDelete(patient.id),
                        ),
                      ],
                    ),
                    // Al hacer click sobre el paciente, redirige a la pantalla de detalle
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientDetailsScreen(patientId: patient.id),
                        ),
                      );
                    },
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