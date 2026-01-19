import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/screens/patient_details_screen.dart';
import 'package:tfg_frontend/features/relation/models/patient.dart';
import 'package:tfg_frontend/features/relation/services/relation_service.dart';

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
        content: const Text('¿Está seguro de que quiere eliminar este paciente?'),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverMedium,
        title: const Text('Pacientes vinculados',style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Ocupa todo el espacio disponible para la lista
            Expanded(
              // -------------------- Lista de pacientes --------------------
              child: ListView.builder(
                itemCount: patients.length, // número de pacientes
                itemBuilder: (context, index) { // cómo construir cada ítem
                  final patient = patients[index]; // paciente actual

                  // Cada paciente se muestra en un contenedor
                  return Container(margin: const EdgeInsets.symmetric(vertical: 7), // espacio entre items
                    
                    // Estilo del contenedor
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    // -------------------- Datos del paciente --------------------
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        '${patient.username[0].toUpperCase()}${patient.username.substring(1)}', // Para que el nombre tenga la primera en mayúscula
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // id del paciente, (momentáneo)
                      subtitle: Text(
                        'ID: ${patient.id}',
                        style: TextStyle(color: Colors.grey[600]),
                      ), 
                      // -------------------- Menú de opciones --------------------
                      trailing: PopupMenuButton(
                        itemBuilder: (ctx) => [
                          // al hacer click, muestra las opciones
                          // Opción de eliminar paciente
                          PopupMenuItem(
                            value: 'delete', // valor asociado a la opción
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: AppColors.delete),
                                SizedBox(width: 8),
                                Text(
                                  'Eliminar',
                                  style: TextStyle(color: AppColors.delete),
                                ),
                              ],
                            ),
                            // -------------------- Eliminar paciente --------------------
                            // al seleccionar la opción, llama a la función de confirmación
                            onTap: () => _confirmDelete(patient.id),
                          ),
                        ],
                      ),

                      // -------------------- Detalles del paciente --------------------
                      // Al hacer click en el paciente, navega a la pantalla de detalles
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientDetailsScreen(patientId: patient.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // -------------------- Botón para generar el código de vinculación --------------------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caregiverMedium,
                foregroundColor: Colors.white,
              ),
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
