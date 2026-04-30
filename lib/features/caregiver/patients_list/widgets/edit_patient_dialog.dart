import 'package:flutter/material.dart';
import 'package:tfg_frontend/models/patient.dart';
import 'package:tfg_frontend/core/enums/disease_stage.dart';

class EditPatientDialog extends StatefulWidget {
  final Patient patient;
  final Future<void> Function(String phone, String notes, String? stage) onSave;

  const EditPatientDialog({super.key, required this.patient, required this.onSave});

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late TextEditingController phoneController;
  late TextEditingController notesController;
  DiseaseStage? diseaseStage;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar paciente'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notas')),
            const SizedBox(height: 10),
            DropdownButton<DiseaseStage>(
              value: diseaseStage,
              hint: const Text('Etapa de la enfermedad'),
              items: DiseaseStage.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (value) => setState(() => diseaseStage = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            await widget.onSave(phoneController.text, notesController.text, diseaseStage?.name);
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}