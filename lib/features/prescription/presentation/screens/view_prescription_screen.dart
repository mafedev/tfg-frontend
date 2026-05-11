import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/prescription_tracking/presentation/screens/prescription_tracking_screen.dart';
import 'package:tfg_frontend/shared/widgets/app_fab.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/prescription/presentation/screens/create_prescription_screen.dart';
import 'package:tfg_frontend/features/prescription/data/caregiver_prescription_service.dart';

class ViewPrescriptionScreen extends StatefulWidget {
  final int patientId;

  const ViewPrescriptionScreen({super.key, required this.patientId});

  @override
  State<ViewPrescriptionScreen> createState() => _ViewPrescriptionScreenState();
}

class _ViewPrescriptionScreenState extends State<ViewPrescriptionScreen> {
  // indica si está cargando los datos
  bool loading = true;
  List<dynamic> medications = []; // es donde se guardan las rutinas de medicamentos

  @override
  void initState() {
    super.initState();
    _loadMedication(); // carga la medicación al iniciar
  }

  // ------------- Carga la medicación del paciente -------------
  void _loadMedication() async {
    try {
      final result = await CaregiverPrescriptionService().getByPatient(widget.patientId);

      setState(() {
        medications = result.where((med) {
          final status = med['status'] ?? 'ACTIVE';
          return status != 'CANCELLED';
        }).toList();

        loading = false; // deja de cargar
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // si está cargando, muestra un indicador de carga
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // si no hay medicación, muestra un mensaje
    if (medications.isEmpty) {
      return Scaffold(
        appBar: const AppLogoAppBar(title: 'Medicación', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(
          child: Text('Este paciente no tiene medicación asignada'),
        ),
      );
    }

    // si hay medicación, la muestra en una lista
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Medicación', backgroundColor: AppColors.caregiverAppBar),

      body: Column(
        children: [
          // ----------- Botón para ver tomas del día ----------
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.caregiverPrimary, foregroundColor: Colors.white),
                // al hacer click, navega a la pantalla de seguimiento de tomas
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionTrackingScreen(patientId: widget.patientId)));
                },
                icon: const Icon(Icons.access_time),
                label: const Text('Ver tomas de hoy'),
              ),
            ),
          ),

          // ----------- Lista de medicación ----------
          Expanded(
            child: ListView.builder(
              itemCount: medications.length, // número de elementos en la lista
              itemBuilder: (context, index) { // cómo construir cada elemento
                final med = medications[index];

          // Cada medicamento se muestra en una card desplegable, con su información
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shadowColor: AppColors.caregiverPrimary.withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

            // Cada card es un ExpansionTile que muestra más detalles al expandir
            child: ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  med['medication']['name'] ?? 'Medicamento sin nombre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ID: ${med['id']}',
                ),
              ),

              // -------------- Tres puntos --------------
              trailing: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),

                // Ícono de editar la medicación
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatePrescriptionScreen(
                          patientId: widget.patientId,
                          existingPrescription: med,
                        ),
                      ),
                    ).then((_) => _loadMedication());
                  }

                  // Ícono de borrar la medicación
                  if (value == 'delete') {
                    await CaregiverPrescriptionService().deletePrescription(
                      med['id'],
                    );
                    _loadMedication();
                  }
                },

                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.caregiverPrimary,
                        ),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.delete),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),

              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                
                // Si tiene desciprción
                if (med['medication']['description'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        med['medication']['description'],
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Dosis: ${med['dose']} ${med['doseUnit'] ?? 'mg'}'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Frecuencia: ${med['frequencyHours'] ?? 'N/A'} h'),
                ),
                if (med['firstDoseTime'] != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Primera dosis: ${med['firstDoseTime']}'),
                  ),
                if (med['startDate'] != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Inicio: ${med['startDate']}'),
                  ),
                if (med['endDate'] != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Fin: ${med['endDate']}'),
                  ),
                if (med['notes'] != null && med['notes'].toString().isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Notas: ${med['notes']}'),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Estado: ${med['status'] ?? 'ACTIVE'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ---------- Botón para agregar nueva prescripción ----------
      floatingActionButton: AppFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreatePrescriptionScreen(patientId: widget.patientId),
            ),
          );
        },
        icon: Icons.add,
        isPatient: false, // cuidador
      ),
    );
  }
}
