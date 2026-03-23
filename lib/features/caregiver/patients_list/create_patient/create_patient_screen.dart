import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/create_patient_service.dart';

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

  String diseaseStage = 'EARLY';
  bool loading = false;

  final PatientService _patientService = PatientService();

  // -------------------- Guardar paciente --------------------
  void _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _patientService.createPatientWithoutUser(
        nameController.text,
        phoneController.text,
        diseaseStage,
        notesController.text,
      );

      if (mounted) Navigator.pop(context, true); // devuelve true para refrescar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nuevo paciente'),
        backgroundColor: AppColors.caregiverAppBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 16),

              // Teléfono
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) =>
                    value == null || value.length < 9 ? 'Teléfono inválido' : null,
              ),

              const SizedBox(height: 16),

              // Etapa
              DropdownButtonFormField<String>(
                value: diseaseStage,
                decoration: const InputDecoration(
                  labelText: 'Estado de la enfermedad',
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
                items: ['EARLY', 'MODERATE', 'ADVANCED']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => diseaseStage = value!),
              ),

              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                ),
                maxLines: 3,
              ),

              const Spacer(),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _savePatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caregiverPrimary,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Crear paciente'),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}