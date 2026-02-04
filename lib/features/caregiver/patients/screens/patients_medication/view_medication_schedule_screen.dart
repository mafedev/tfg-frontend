import 'package:flutter/material.dart';
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
          
          // muestra la información del medicamento
          return ListTile(
            title: Text('Medicamento ID: ${med['id']}'),
            subtitle: Text('Dosis: ${med['dose']}'),
          );
        },
      ),

      // ---------- Botón para agregar nueva rutina de medicación ----------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // navegar
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
