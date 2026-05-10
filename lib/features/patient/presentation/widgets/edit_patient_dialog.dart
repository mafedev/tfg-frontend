import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/patients_details_controller.dart';
import 'package:tfg_frontend/shared/enums/user/patient/disease_stage.dart';
import 'package:tfg_frontend/shared/models/patient.dart';

class EditPatientDialog extends StatefulWidget {
  final Patient patient;
  final Function(Patient updatedPatient) onUpdated;

  const EditPatientDialog({
    super.key,
    required this.patient,
    required this.onUpdated,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  final PatientDetailsController _controller = PatientDetailsController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController phoneController;
  late TextEditingController notesController;
  DiseaseStage? diseaseStage;
  bool updatingPatient = false;

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.patient.phone);
    notesController = TextEditingController(text: widget.patient.notes);
    diseaseStage = widget.patient.diseaseStage;
  }

  @override
  void dispose() {
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }

  // ------- Guarda los cambios -------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      updatingPatient = true;
    });

    await _controller.updatePatient(
      patientId: widget.patient.id,
      phone: phoneController.text,
      notes: notesController.text,
      diseaseStage: diseaseStage?.name,
    );

    final updatedPatient = Patient(
      id: widget.patient.id,
      username: widget.patient.username,
      name: widget.patient.name,
      phone: phoneController.text,
      notes: notesController.text,
      diseaseStage: diseaseStage,
    );

    widget.onUpdated(updatedPatient);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar paciente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es obligatorio';
                  }

                  if (value.length < 9) {
                    return 'Número inválido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<DiseaseStage>(
                value: diseaseStage,
                decoration: const InputDecoration(
                  labelText: 'Etapa enfermedad',
                  prefixIcon: Icon(Icons.face),
                  border: OutlineInputBorder(),
                ),
                items: DiseaseStage.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    diseaseStage = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: updatingPatient ? null : _save,
          child: updatingPatient
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
