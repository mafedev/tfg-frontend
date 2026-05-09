import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/create_patient_screen.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/patient_details_screen.dart';
import 'package:tfg_frontend/shared/models/patient.dart';
import 'package:tfg_frontend/features/relation/data/relation_service.dart';

class CaregiverPatientsScreen extends StatefulWidget {
  const CaregiverPatientsScreen({super.key});

  @override
  State<CaregiverPatientsScreen> createState() =>
      _CaregiverPatientsScreenState();
}

class _CaregiverPatientsScreenState extends State<CaregiverPatientsScreen> {
  // -------------------- Variables de estado --------------------
  bool loadingPatients = true;
  bool generatingCode = false;

  String? relationCode;
  final RelationService _relationService = RelationService();
  List<Patient> patients = []; // lista de pacientes por cuidador

  @override
  void initState() {
    super.initState();
    _loadPatients(); // al abrir la pantalla, carga la lista
  }

  // Espera que el backend devuelva el código
  Future<void> _generateCode() async {
    // indica que se está generando el código y muestra que está cargando
    setState(() {
      generatingCode = true;
    });

    final code = await _relationService.generateRelationCode();

    if (!mounted) return; // si el widget ya no está en pantalla, no hace nada

    setState(() {
      relationCode = code;
      generatingCode = false; // ya no está generando el código
    });

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el código')),
      );
    }
  }

  // Obtiene la lista de pacientes
  Future<void> _loadPatients() async {
    // muestra que se está cargando la lista
    setState(() {
      loadingPatients = true;
    });

    // intenta obtener la lista de pacientes desde el backend
    try {
      final fetchedPatients = await _relationService
          .getPatients(); // obtiene la lista de pacientes vinculados al cuidador

      if (!mounted) return; // si el widget ya no está en pantalla, no hace nada

      // actualiza el estado con la lista obtenida y oculta el indicador de carga
      setState(() {
        patients = fetchedPatients;
        loadingPatients = false;
      });
    } catch (e) {
      // si hay un error, oculta el indicador de carga y muestra un mensaje de error
      if (!mounted) return;

      setState(() {
        loadingPatients = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error cargando pacientes')));
    }
  }

  // Elimina la relación con un paciente
  void _deletePatient(int patientId) async {
    try {
      await _relationService.deleteRelation(patientId);
      _loadPatients();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Relación eliminada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error eliminando relación')),
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

  // Permite poder copiar el código al portapapeles
  void _copyCodeToClipboard() {
    if (relationCode != null) {
      Clipboard.setData(ClipboardData(text: relationCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código copiado al portapapeles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Pacientes vinculados', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
            // -------------------- Lista de pacientes --------------------
              child: Builder(
                builder: (context) {
                  if (loadingPatients) {
                    // Mientras cargan los pacientes, se muestra el círculo de carga
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (patients.isEmpty) {
                    // Si no hay pacientes, se muestra el mensaje
                    return const Center(
                      child: Text(
                        'No tienes pacientes vinculados',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Si hay pacientes, se muestra la lista
                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index]; // obtiene el paciente por posición

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            patient.username?.isNotEmpty == true ? patient.username![0].toUpperCase() + patient.username!.substring(1) : patient.name?.isNotEmpty == true ? patient.name![0].toUpperCase() + patient.name!.substring(1) : 'Sin nombre',
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
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreatePatientScreen(),
                  ),
                );

                if (created == true) {
                  _loadPatients();
                }
              },
              child: const Text('Crear paciente sin cuenta'),
            ),

            // -------------------- Botón para generar el código de vinculación --------------------
            if (generatingCode)
              ElevatedButton(
                onPressed: null, // desactivado mientras carga
                child: const SizedBox( height: 20, width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: _generateCode,
                child: const Text('Agregar paciente'),
              ),

            const SizedBox(height: 12),

            // -------------------- Muestra el código generado --------------------
            if (relationCode != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Código generado: $relationCode',
                    style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: _copyCodeToClipboard,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
