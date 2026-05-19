import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/create_patient_screen.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/patient_details_screen.dart';
import 'package:tfg_frontend/shared/models/patient.dart';
import 'package:tfg_frontend/features/relation/data/relation_service.dart';
import 'package:tfg_frontend/shared/widgets/app_primary_icon_button.dart';
import 'package:tfg_frontend/shared/widgets/app_secondary_icon_button.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:tfg_frontend/shared/widgets/confirm_delete_dialog.dart';

class CaregiverPatientsScreen extends StatefulWidget {
  const CaregiverPatientsScreen({super.key});

  @override
  State<CaregiverPatientsScreen> createState() =>
      _CaregiverPatientsScreenState();
}

class _CaregiverPatientsScreenState extends State<CaregiverPatientsScreen> {
  // -------------------- Variables de estado --------------------
  bool loadingPatients = true;
  bool generatingCode = false;

  String? relationCode;
  final RelationService _relationService = RelationService();
  List<Patient> patients = []; // lista de pacientes por cuidador

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients(); // al abrir la pantalla, carga la lista
  }

  // Espera que el backend devuelva el código
  Future<void> _generateCode() async {
    // indica que se está generando el código y muestra que está cargando
    setState(() {
      generatingCode = true;
    });

    final code = await _relationService.generateRelationCode();

    if (!mounted) return; // si el widget ya no está en pantalla, no hace nada

    setState(() {
      relationCode = code;
      generatingCode = false; // ya no está generando el código
    });

    if (code == null) {
      AppSnackBar.showError(context, 'Error generando el código');
    }
  }

  // Obtiene la lista de pacientes
  Future<void> _loadPatients() async {
    // muestra que se está cargando la lista
    setState(() {
      loadingPatients = true;
    });

    // intenta obtener la lista de pacientes desde el backend
    try {
      final fetchedPatients = await _relationService
          .getPatients(); // obtiene la lista de pacientes vinculados al cuidador

      if (!mounted) return; // si el widget ya no está en pantalla, no hace nada

      // actualiza el estado con la lista obtenida y oculta el indicador de carga
      setState(() {
        patients = fetchedPatients;
        loadingPatients = false;
      });
    } catch (e) {
      // si hay un error, oculta el indicador de carga y muestra un mensaje de error
      if (!mounted) return;

      setState(() {
        loadingPatients = false;
      });

      AppSnackBar.showError(context, 'Error cargando pacientes');
    }
  }

  // Elimina la relación con un paciente
  void _deletePatient(int patientId) async {
    try {
      await _relationService.deleteRelation(patientId);
      _loadPatients();

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Relación eliminada correctamente');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Error eliminando relación');
      }
    }
  }

  // Permite poder copiar el código al portapapeles
  void _copyCodeToClipboard() {
    if (relationCode != null) {
      Clipboard.setData(ClipboardData(text: relationCode!));
      AppSnackBar.showInfo(context, 'Código copiado al portapapeles');
    }
  }

  String getPatientTitle(Patient patient) {
    final text = (patient.username?.isNotEmpty == true)
        ? patient.username!
        : (patient.name?.isNotEmpty == true)
        ? patient.name!
        : 'Sin nombre';

    return text[0].toUpperCase() + text.substring(1);
  }

  List<Patient> _filteredPatients() {
    final q = searchQuery.toLowerCase();

    return patients.where((p) {
      final name = getPatientTitle(p).toLowerCase();
      final id = p.id.toString();

      return name.contains(q) || id.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Pacientes vinculados', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },

              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(vertical: 0),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.caregiverPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
            // -------------------- Lista de pacientes --------------------
              child: Builder(
                builder: (context) {
                  if (loadingPatients) {
                    // Mientras cargan los pacientes, se muestra el círculo de carga
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (patients.isEmpty) {
                    // Si no hay pacientes, se muestra el mensaje
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        child: const Text('No tienes pacientes vinculados', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    );
                  }

                  // Si hay pacientes, se muestra la lista
                  final list = _filteredPatients();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final patient = list[index]; // obtiene el paciente por posición

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(color: AppColors.caregiverCard, borderRadius: BorderRadius.circular(12)),

                        // Fila
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18,vertical: 8),

                          leading: CircleAvatar(
                            backgroundColor: AppColors.caregiverAppBar.withOpacity(0.10),
                            child: const Icon(Icons.person, color: AppColors.caregiverAppBar),
                          ),

                          // ----- Nombre -----
                          title: Text(
                            getPatientTitle(patient),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          
                          // ----- Id del paciente(momentáneo) -----
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('ID: ${patient.id}', style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          
                          // -------------------- Menú de opciones --------------------
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (_) => ConfirmDeleteDialog(
                                    title: "Eliminar paciente",
                                    message: "Se eliminará la relación con este paciente. Sus datos y registros permanecerán intactos. Esta acción es irreversible.",
                                    onConfirm: () => _deletePatient(patient.id),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (ctx) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: AppColors.delete),
                                    SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: AppColors.delete)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // -------------------- Detalles del paciente --------------------
                          // Al hacer click en el paciente, navega a la pantalla de detalles
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDetailsScreen(patientId: patient.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // -------------------- Botones --------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  // ----- Generar código para vincular -----
                  AppPrimaryIconButton(text: generatingCode ? "Generando código..." : "Agregar paciente",
                    icon: Icons.link,
                    loading: generatingCode,
                    onPressed: _generateCode,
                  ),

                  const SizedBox(height: 12),

                  // ----- Crear paciente -----
                  AppSecondaryIconButton(
                    text: "Crear paciente sin cuenta",
                    icon: Icons.person_add,
                    onPressed: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePatientScreen(),
                        ),
                      );

                      if (created == true) {
                        _loadPatients();
                      }
                    },
                  ),

                  // ----- Código de vinculación -----
                  if (relationCode != null) ...[
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.caregiverAppBar.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ----- Código -----
                          Text(
                            relationCode!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1.2,
                            ),
                          ),

                          const SizedBox(width: 10),

                          // ----- Botón para copiar -----
                          InkWell(
                            onTap: _copyCodeToClipboard,
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.copy, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
