import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/enums/allergies_severity.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_allergies_service.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';

class PatientAllergiesScreen extends StatefulWidget {
  final int patientId;

  const PatientAllergiesScreen({super.key, required this.patientId});

  @override
  State<PatientAllergiesScreen> createState() => _PatientAllergiesScreenState();
}

class _PatientAllergiesScreenState extends State<PatientAllergiesScreen> {
  final AllergyService _service = AllergyService();

  List<Map<String, dynamic>> allergies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      allergies = await _service.getByPatient(widget.patientId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }

    setState(() => loading = false);
  }

  void _create() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    AllergySeverity severity = AllergySeverity.LOW;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva alergia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<AllergySeverity>(
              value: severity,
              items: AllergySeverity.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => severity = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.create(
                patientId: widget.patientId,
                name: nameController.text,
                description: descController.text,
                severity: severity,
              );

              Navigator.pop(context);
              _load();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _delete(int allergyId) async {
    try {
      await _service.delete(patientId: widget.patientId, allergyId: allergyId);

      setState(() {
        allergies.removeWhere((a) => a['allergy']['id'] == allergyId);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alergia eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _editSeverity(Map<String, dynamic> allergyData) async {
    AllergySeverity severity = AllergySeverity.values.firstWhere(
      (e) => e.name == allergyData['severity'],
      orElse: () => AllergySeverity.LOW,
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar severidad'),
        content: DropdownButtonFormField<AllergySeverity>(
          value: severity,
          items: AllergySeverity.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
              .toList(),
          onChanged: (v) => severity = v!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.updateSeverity(
                patientId: widget.patientId,
                allergyId: allergyData['allergy']['id'],
                severity: severity,
              );

              Navigator.pop(context);
              _load();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(
        title: 'Alergias',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        backgroundColor: AppColors.caregiverPrimary,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : allergies.isEmpty
          ? const Center(child: Text('Sin alergias'))
          : ListView.builder(
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                final a = allergies[index];

                return ListTile(
                  title: Text(a['allergy']['name'] ?? 'Sin nombre'),
                  subtitle: Text(a['severity'] ?? 'Sin severidad'),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editSeverity(a),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(a['allergy']['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
