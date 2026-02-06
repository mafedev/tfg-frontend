import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/screens/patients_medication/create_medication_schedule_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_medication_service.dart';

class ViewMedicationScheduleScreen extends StatefulWidget {
  final int patientId;

  const ViewMedicationScheduleScreen({super.key, required this.patientId});

  @override
  State<ViewMedicationScheduleScreen> createState() => _ViewMedicationScheduleScreenState();
}

class _ViewMedicationScheduleScreenState extends State<ViewMedicationScheduleScreen> {
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
      final result = await CaregiverMedicationService().getMedicationSchedulesPatient(widget.patientId); // obtiene la medicación usando el id del paciente

      setState(() {
        medications = result; // guarda la medicación obtenida
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

      // ----------- Lista de medicación ----------
      body: ListView.builder(
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
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ID: ${med['id']}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),

              // -------------- Tres puntos superiores --------------
              trailing: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),

                // Ícono de editar la medicación
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateMedicationScheduleScreen(
                          patientId: widget.patientId,
                          existingSchedule: med,
                        ),
                      ),
                    ).then((_) => _loadMedication());
                  }

                  // Ícono de borrar la medicación
                  if (value == 'delete') {
                    await CaregiverMedicationService().deleteMedicationSchedule(
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
                  child: Text('Dosis: ${med['dose']}'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Frecuencia: ${med['frequencyHours'] ?? 'Ninguna'} h'),
                ),
              ],
            ),
          );

        },
      ),

      // ---------- Botón para agregar nueva rutina de medicación ----------
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.caregiverButtonPrimary,
        foregroundColor: AppColors.textOnDark,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateMedicationScheduleScreen(patientId: widget.patientId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
