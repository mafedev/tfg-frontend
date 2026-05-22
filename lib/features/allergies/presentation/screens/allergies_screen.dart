import 'package:flutter/material.dart';
import 'package:tfg_frontend/shared/enums/allergies/allergies_severity.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/allergies/data/caregiver_allergies_service.dart';
import 'package:tfg_frontend/shared/widgets/app_fab.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_search_bar.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:tfg_frontend/shared/widgets/confirm_delete_dialog.dart';

class PatientAllergiesScreen extends StatefulWidget {
  final int patientId; // id del paciente para cargar sus alergias

  const PatientAllergiesScreen({super.key, required this.patientId});

  @override
  State<PatientAllergiesScreen> createState() => _PatientAllergiesScreenState(); // crea el estado
}

class _PatientAllergiesScreenState extends State<PatientAllergiesScreen> {
  final AllergyService _service = AllergyService(); // instancia del servicio de alergias
  List<Map<String, dynamic>> allergies = []; // lista de alergias del paciente
  bool loading = true; // indicador de carga

  List<Map<String, dynamic>> filteredAllergies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load(); // carga las alergias al iniciar la pantalla
  }

  // -------------------- Cargar alergias --------------------
  Future<void> _load() async {
    setState(() => loading = true);

    try {
      allergies = await _service.getByPatient(widget.patientId);
      filteredAllergies = List.from(allergies);
    } catch (e) {
      AppSnackBar.showError(context, 'Error cargando alergias');
    }
    setState(() => loading = false);
  }

  void _filterAllergies(String query) {
  final text = query.toLowerCase();

  setState(() {
    filteredAllergies = allergies.where((allergy) {
      final name =
          allergy['allergy']['name']?.toString().toLowerCase() ?? '';

      final desc =
          allergy['allergy']['description']?.toString().toLowerCase() ?? '';

      return name.contains(text) || desc.contains(text);
    }).toList();
  });
}

  // -------------------- Crear nueva alergia --------------------
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
                  .map((allergy) => DropdownMenuItem(
                      value: allergy,
                      child: Text(allergy.name),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) => severity = newValue!,
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

  // -------------------- Eliminar alergia --------------------
  void _delete(int allergyId) async {
    try {
      await _service.delete(patientId: widget.patientId, allergyId: allergyId);

      setState(() {
        allergies.removeWhere(
          (allergy) => allergy['allergy']['id'] == allergyId,
        );

        filteredAllergies.removeWhere(
          (allergy) => allergy['allergy']['id'] == allergyId,
        );
      });
      AppSnackBar.showSuccess(context, 'Alergia eliminada');
    } catch (e) {
      AppSnackBar.showError(context, 'Error eliminando alergia');
    }
  }

  // -------------------- Editar severidad de la alergia --------------------
  void _editSeverity(Map<String, dynamic> allergyData) async {
    AllergySeverity severity = AllergySeverity.values.firstWhere(
      (allergySeverity) => allergySeverity.name == allergyData['severity'],
      orElse: () => AllergySeverity.LOW,
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar severidad'),
        content: DropdownButtonFormField<AllergySeverity>(
          value: severity,
          items: AllergySeverity.values
              .map((allergySeverity) => DropdownMenuItem(
                  value: allergySeverity,
                  child: Text(allergySeverity.name),
                ),
              )
              .toList(),
          onChanged: (newValue) => severity = newValue!,
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

  // -------------------- Color chips --------------------
  Color _chipColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.redAccent;
      case 'HIGH':
        return Colors.orange;
      default:
        return AppColors.patientAccentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(
        title: 'Alergias',
        backgroundColor: AppColors.caregiverAppBar,
      ),
      floatingActionButton: AppFAB(
        onPressed: _create
      ),

      body: Builder(
        builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (allergies.isEmpty) {
            return const Center(child: Text('Sin alergias'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: 'Buscar alergias...',
                  onChanged: _filterAllergies,
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredAllergies.length,
                  itemBuilder: (context, index) {
                    final a = filteredAllergies[index];

                    final name = a['allergy']['name'] ?? 'Sin nombre';
                    final desc =
                        a['allergy']['description'] ?? 'Sin descripción';
                    final severity = a['severity'] ?? 'LOW';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.caregiverPrimary,
                                  ),
                                ),
                              ),

                              // -------- Tres puntos --------
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),

                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editSeverity(a);
                                  }
                                  if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmDeleteDialog(
                                          title: "Eliminar alergia",
                                          message: "Esta acción eliminará la alergia del historial del paciente y no se puede deshacer. ¿Desea continuar?",
                                          onConfirm: () => _delete(a['allergy']['id']),
                                        );
                                      },
                                    );
                                  }
                                },

                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Eliminar'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Chip(
                              label: Text(
                                severity,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: _chipColor(severity).withOpacity(0.15),
                              labelStyle: TextStyle(color: _chipColor(severity)),
                              shape: const StadiumBorder(),
                              side: BorderSide.none,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
