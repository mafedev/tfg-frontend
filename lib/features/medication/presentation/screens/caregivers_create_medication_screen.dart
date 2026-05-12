import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/medication/data/caregiver_medication_service.dart';
import 'package:tfg_frontend/shared/enums/medication/medication_type.dart';

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

  // tipo seleccionado en el Dropdown
  MedicationType _selectedType = MedicationType.TABLET;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Medicamentos', backgroundColor: AppColors.caregiverAppBar),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Crear medicamento",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // ----------- Campos de texto ---------
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Tipo de medicamento",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                // ---------- Dropdown ----------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MedicationType>(
                      value: _selectedType,
                      isExpanded: true,
                      items: MedicationType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.name.replaceAll('_', ' ').toLowerCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (t) {
                        if (t != null) setState(() => _selectedType = t);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ----------- Botón guardar ---------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.caregiverPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await CaregiverMedicationService().createMedication(
                          _name.text,
                          _description.text,
                          _selectedType,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Medicamento creado con éxito'),
                          ),
                        );

                        _name.clear();
                        _description.clear();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
