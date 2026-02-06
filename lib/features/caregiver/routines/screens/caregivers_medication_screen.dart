import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/core/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients/services/caregiver_medication_service.dart';

class CaregiversMedicationScreen extends StatefulWidget {
  const CaregiversMedicationScreen({super.key});

  @override
  State<CaregiversMedicationScreen> createState() =>
      _CaregiversMedicationScreenState();
}

class _CaregiversMedicationScreenState extends State<CaregiversMedicationScreen> {
  // Controladores para los TextField
  final _name = TextEditingController();
  final _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Medicamentos', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----------- Campos de texto ---------
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 20),

            // ----------- Botón guardar medicamento ---------
            ElevatedButton(
              onPressed: () async {
                try {
                  // al presionarlo, intenta crear el medicamento
                  await CaregiverMedicationService().createMedication(_name.text,_description.text);
                  // si sale bien, muestra el mensaje
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medicamento creado con éxito')));
                  _name.clear(); // se limpian los campos
                  _description.clear();
                } catch (e) { // si sale mal, muestra el error
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
