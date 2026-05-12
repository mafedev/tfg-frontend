import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/enums/user/patient/disease_stage.dart';
import 'package:tfg_frontend/features/patient/data/patient_service.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();

  DiseaseStage diseaseStage = DiseaseStage.EARLY;
  bool loading = false;

  final PatientService _patientService = PatientService();

  // -------------------- Guardar paciente --------------------
  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _patientService.createPatientWithoutUser(
        nameController.text.trim(),
        phoneController.text.trim(),
        diseaseStage,
        notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente creado correctamente')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Nuevo paciente', backgroundColor: AppColors.caregiverAppBar),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              color: AppColors.caregiverCard,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del paciente',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Completa los datos del paciente',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),

                      const SizedBox(height: 28),

                      // ----- Nombre -----
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // ----- Teléfono -----
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El teléfono es obligatorio';
                          }

                          if (value.trim().length < 9) {
                            return 'Teléfono inválido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // ----- Estado de la enfermedad -----
                      DropdownButtonFormField<DiseaseStage>(
                        value: diseaseStage,
                        decoration: const InputDecoration(
                          labelText: 'Estado de la enfermedad',
                          prefixIcon: Icon(Icons.health_and_safety),
                          border: OutlineInputBorder(),
                        ),
                        items: DiseaseStage.values
                            .map((estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => diseaseStage = value);
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      // ----- Notas -----
                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Notas',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ----- Botón crear paciente -----
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : _savePatient,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.caregiverPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Crear paciente',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
