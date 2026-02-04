import 'package:flutter/material.dart';
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
        appBar: AppBar(title: const Text('Medicación')),
        body: const Center(
          child: Text('Este paciente no tiene medicación asignada'),
        ),
      );
    }

    // si hay medicación, la muestra en una lista
    return Scaffold(
      appBar: AppBar(title: const Text('Medicación')),
      
      // ----------- Lista de medicación ----------
      body: ListView.builder(
        itemCount: medications.length, // número de elementos en la lista
        itemBuilder: (context, index) { // cómo construir cada elemento
          final med = medications[index];

          // Cada medicamento se muestra en una card desplegable, con su información
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            
            // Cada card es un ExpansionTile que muestra más detalles al expandir
            child: ExpansionTile(
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  med['medication']['name'] ?? 'Medicamento sin nombre',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: Text('ID: ${med['id']}'),
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
                  child: Text(
                      'Frecuencia: ${med['frequencyHours'] ?? 'Ninguna'} h'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    
                    // ---------- Botón para editar rutina de medicación ----------
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateMedicationScheduleScreen(
                              patientId: widget.patientId,
                              existingSchedule: med,
                            ),
                          ),
                        ).then( (_) => _loadMedication()); // cuando volvemos de editar, se actualiza la lista
                      },
                    ),
                    
                    // ---------- Botón para borrar rutina de medicación ----------
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await CaregiverMedicationService().deleteMedicationSchedule(med['id']);
                        _loadMedication(); // recarga la lista
                      },
                    ),
                  ],
                ),
              ],
            ),
          );

        },
      ),

      // ---------- Botón para agregar nueva rutina de medicación ----------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                CreateMedicationScheduleScreen(patientId: widget.patientId)
              )
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
