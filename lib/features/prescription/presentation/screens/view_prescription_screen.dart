import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/prescription_tracking/presentation/screens/prescription_tracking_screen.dart';
import 'package:tfg_frontend/shared/widgets/app_fab.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/prescription/presentation/screens/create_prescription_screen.dart';
import 'package:tfg_frontend/features/prescription/data/caregiver_prescription_service.dart';
import 'package:tfg_frontend/shared/widgets/confirm_delete_dialog.dart';

class ViewPrescriptionScreen extends StatefulWidget {
  final int patientId;

  const ViewPrescriptionScreen({super.key, required this.patientId});

  @override
  State<ViewPrescriptionScreen> createState() => _ViewPrescriptionScreenState();
}

class _ViewPrescriptionScreenState extends State<ViewPrescriptionScreen> {
  // indica si está cargando los datos
  bool loading = true;
  List<dynamic> medications =
      []; // es donde se guardan las rutinas de medicamentos
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMedication(); // carga la medicación al iniciar
  }

  // ------------- Carga la medicación del paciente -------------
  void _loadMedication() async {
    try {
      final result = await CaregiverPrescriptionService().getByPatient(
        widget.patientId,
      );

      setState(() {
        medications = result.where((med) {
          final status = med['status'] ?? 'ACTIVE';
          return status != 'CANCELLED';
        }).toList();

        loading = false; // deja de cargar
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  List<dynamic> _filteredMedications() {
    final q = searchQuery.toLowerCase();

    return medications.where((m) {
      final name = (m['medication']['name'] ?? '').toString().toLowerCase();
      final notes = (m['notes'] ?? '').toString().toLowerCase();
      final status = (m['status'] ?? '').toString().toLowerCase();

      return name.contains(q) || notes.contains(q) || status.contains(q);
    }).toList();
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
        appBar: const AppLogoAppBar(title: 'Prescripciones', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(
          child: Text('Este paciente no tiene medicación asignada'),
        ),
      );
    }

    final filtered = _filteredMedications();
    
    // si hay medicación, la muestra en una lista
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Prescripciones', backgroundColor: AppColors.caregiverAppBar),

      body: Column(
        children: [
          // ----------- Botón para ver tomas del día ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                // Search bar
                Container(
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
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Buscar medicamento...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionTrackingScreen(patientId: widget.patientId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.caregiverSecondary,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.caregiverPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ver tomas de hoy',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ----------- Lista de medicación ----------
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No hay medicamentos'))
                : ListView.builder(
                    itemCount: filtered.length, // número de elementos en la lista
                    itemBuilder: (context, index) { // cómo construir cada elemento
                      final med = filtered[index];
                // Cada medicamento se muestra en una card desplegable, con su información
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shadowColor: AppColors.caregiverPrimary.withOpacity(0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  // Cada card es un ExpansionTile que muestra más detalles al expandir
                        child: ExpansionTile(
                          title: Text(
                            med['medication']['name'] ?? 'Medicamento sin nombre',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'ID ${med['id']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                    // -------------- Tres puntos --------------
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.black),

                      // Ícono de editar la medicación
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreatePrescriptionScreen(
                                      patientId: widget.patientId,
                                      existingPrescription: med,
                                    ),
                                  ),
                                ).then((_) => _loadMedication());
                              }

                        // Ícono de borrar la medicación
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmDeleteDialog(
                                      title: "Eliminar prescripción",
                                      message: "Esta prescripción dejará de ser visible, pero los registros de seguimiento asociados no se eliminarán por seguridad.",
                                      onConfirm: () async {
                                        await CaregiverPrescriptionService().deletePrescription(med['id']);
                                        _loadMedication();
                                      },
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
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: AppColors.caregiverPrimary,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: AppColors.delete),
                                    SizedBox(width: 8),
                                    Text('Eliminar'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            const SizedBox(height: 10),

                            _infoLine(
                              'Dosis',
                              '${med['dose']} ${med['doseUnit'] ?? 'mg'}',
                            ),
                            _infoLine(
                              'Frecuencia',
                              '${med['frequencyHours'] ?? 'N/A'} h',
                            ),

                            if (med['firstDoseTime'] != null)
                              _infoLine('Primera dosis', med['firstDoseTime']),

                            if (med['startDate'] != null || med['endDate'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 110,
                                      child: Text('Duración',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text('${med['startDate'] ?? '--'} → ${med['endDate'] ?? '--'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (med['notes'] != null &&
                                med['notes'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: _infoLine('Notas', med['notes']),
                              ),

                            const SizedBox(height: 10),

                      // Estado a la derecha
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(), // mantiene alineación izquierda
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.caregiverPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    med['status'] ?? 'ACTIVE',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.caregiverPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ---------- Botón para agregar nueva prescripción ----------
      floatingActionButton: AppFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreatePrescriptionScreen(patientId: widget.patientId),
            ),
          );
        },
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // clave para alineación limpia
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
