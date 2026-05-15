import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/medication/data/caregiver_medication_service.dart';
import 'package:tfg_frontend/shared/enums/medication/medication_type.dart';
import 'package:tfg_frontend/shared/dtos/medication/medication_response.dart';

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
  final service = CaregiverMedicationService();

  List<MedicationResponse> medications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------- Cargar medicamentos ----------
  Future<void> _load() async {
    try {
      final data = await service.getMedications();
      setState(() {
        medications = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando medicamentos: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ---------- Input style ----------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.caregiverSecondary, width: 1.2),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.caregiverPrimary, width: 2),
      ),
    );
  }

  // ---------- Guardar ----------
  Future<void> _save() async {
    try {
      await service.createMedication(
        _name.text,
        _description.text,
        _selectedType,
      );

      _name.clear();
      _description.clear();

      await _load();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Medicamento creado")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Medicamentos', backgroundColor: AppColors.caregiverAppBar),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // -------------------- Crear medicamento --------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Crear medicamento",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.caregiverPrimary,),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _name,
                    decoration: _inputDecoration("Nombre"),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _description,
                    maxLines: 2,
                    decoration: _inputDecoration("Descripción"),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<MedicationType>(
                    value: _selectedType,
                    decoration: _inputDecoration("Tipo"),
                    items: MedicationType.values
                        .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (t) {
                      if (t != null) setState(() => _selectedType = t);
                    },
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caregiverPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _save,
                      child: const Text("Guardar"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Medicamentos existentes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.caregiverPrimary,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // -------------------- Medicamentos existentes --------------------
            Expanded(
              child: Builder(
                builder: (context) {
                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (medications.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'No hay medicamentos creados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final m = medications[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capitalize(m.name),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.caregiverPrimary,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                m.type,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                m.description ?? 'Sin descripción',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
