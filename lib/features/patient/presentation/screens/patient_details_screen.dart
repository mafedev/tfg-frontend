import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/allergies/presentation/screens/allergies_screen.dart';
import 'package:tfg_frontend/features/appointment/presentation/screens/create_appointment_screen.dart';
import 'package:tfg_frontend/features/appointment/presentation/screens/view_appointment_screen.dart';
import 'package:tfg_frontend/features/patient/presentation/screens/patients_details_controller.dart';
import 'package:tfg_frontend/features/patient/presentation/widgets/edit_patient_dialog.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/prescription/presentation/screens/create_prescription_screen.dart';
import 'package:tfg_frontend/features/prescription/presentation/screens/view_prescription_screen.dart';
import 'package:tfg_frontend/features/routines/presentation/screens/create_routine_screen.dart';
import 'package:tfg_frontend/features/routines/presentation/screens/view_patient_routine.dart';
import 'package:tfg_frontend/shared/models/patient.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  // Recibe el id del paciente
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  // Contiene el paciente una vez se obtenga la respuesta
  // Es nullable porque al inicio aún no se ha cargado la información
  Patient? patient;

  // Para saber si el paciente tiene rutina creada
  bool loadingRoutine = true; // indica si se está cargando la rutina
  bool hasRoutine = false; // indica si el paciente tiene rutina creada

  // Para saber si el paciente tiene medicación asignada
  bool loadingMedication = true;
  bool hasMedication = false;

  bool loadingAppointments = true;
  bool hasAppointments = false;

  bool updatingPatient = false;
  // Controlador que maneja la lógica de esta pantalla
  final PatientDetailsController _controller = PatientDetailsController();

  @override
  void initState() {
    super.initState();
    _loadPatient();
    _checkRoutine(); // verifica si tiene rutina creada
    _checkMedication(); // verifica si tiene medicación asignada
    _checkAppointments();
  }

  // ---------- Cargar paciente ----------
  Future<void> _loadPatient() async {
    final result = await _controller.loadPatient(widget.patientId);
    setState(() => patient = result);
  }

  // ---------- Cargar rutina ----------
  Future<void> _checkRoutine() async {
    try {
      final result = await _controller.hasRoutine(widget.patientId);
      setState(() {
        hasRoutine = result;
        loadingRoutine = false; // ya no está cargando
      });
    } catch (e) {
      setState(() => loadingRoutine = false); // en caso de error, solo indica que ya no está cargando
    }
  }

  // ---------- Cargar medicación ----------
  Future<void> _checkMedication() async {
    try {
      final result = await _controller.hasMedication(widget.patientId);
      setState(() {
        hasMedication = result;
        loadingMedication = false; // ya no está cargando
      });
    } catch (e) {
      setState(() => loadingMedication = false);
    }
  }

  // ---------- Cargar citas ----------
  Future<void> _checkAppointments() async {
    try {
      final result = await _controller.hasAppointments(widget.patientId);
      setState(() {
        hasAppointments = result;
        loadingAppointments = false;
      });
    } catch (e) {
      setState(() => loadingAppointments = false);
    }
  }

  // ---------- Mayúscula ----------
  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    } else {
      return text[0].toUpperCase() + text.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si patient es null, mostramos un mensaje de carga
    if (patient == null) {
      return Scaffold(
        backgroundColor: AppColors.caregiverBackground,
        appBar: const AppLogoAppBar(title: 'Detalle del paciente', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    // Cuando el paciente ya cargo, muestra los datos
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: const AppLogoAppBar(title: 'Detalle del paciente', backgroundColor: AppColors.caregiverAppBar),

      // SingleChildScrollView para que se pueda scrollear en pantallas pequeñas
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
                color: AppColors.caregiverCard,

              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Stack( //para poner unos encima de otros
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ---------- Nombre ----------
                                    Text(
                                      capitalize( patient!.username ?? patient!.name ?? 'Sin nombre'),
                                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                    ),

                                    const SizedBox(height: 14),

                                    _statusChip(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // ---------- avatar ----------
                              CircleAvatar(radius: 36,backgroundColor: AppColors.caregiverCardLigth,
                                child: const Icon(Icons.person, size: 40,color: AppColors.caregiverAppBar),
                              ),
                            ],
                          ),
                        ),

                        // ---------- Editar paciente ----------
                        // El botón de editar se posiciona en la esquina superior derecha del card encima del avatar
                        Positioned(
                          top: -8,
                          right: -10,
                          child: IconButton(
                            onPressed: () async {
                              if (patient == null) return;

                              await showDialog(
                                context: context,
                                builder: (_) => EditPatientDialog(
                                  patient: patient!,
                                  onUpdated: (updatedPatient) {
                                    setState(() {
                                      patient = updatedPatient;
                                    });
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 22, color: AppColors.caregiverAppBar,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // ---------- Información del paciente ----------
                    // ---------- Teléfono ----------
                    _infoCard('Teléfono', patient!.phone, Icons.phone),

                    const SizedBox(height: 14),

                    // ---------- Notas ----------
                    _infoCard('Notas', patient!.notes, Icons.notes),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // -------------------- Botónes --------------------
                    Column(
                      children: [
                        // ---------- Rutina ----------
                        _actionTile(
                          title: hasRoutine ? 'Ver rutina' : 'Crear rutina',
                          icon: Icons.schedule,
                          color: AppColors.routineAction,
                          loading: loadingRoutine,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => hasRoutine
                                    ? ViewRoutineScreen(patientId: patient!.id)
                                    : CreateRoutineScreen(
                                        patientId: patient!.id,
                                        isEdit: false,
                                      ),
                              ),
                            );
                            _checkRoutine();
                          },
                        ),

                        const SizedBox(height: 12),

                        // ---------- Prescripciones ----------
                        _actionTile(
                          title: hasMedication
                              ? 'Ver prescripciones'
                              : 'Crear prescripciones',
                          icon: Icons.medication,
                          color: AppColors.medicationAction,
                          loading: loadingMedication,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => hasMedication
                                    ? ViewPrescriptionScreen(
                                        patientId: patient!.id,
                                      )
                                    : CreatePrescriptionScreen(
                                        patientId: patient!.id,
                                      ),
                              ),
                            );
                            _checkMedication();
                          },
                        ),

                        const SizedBox(height: 12),

                        // ---------- Alergias ----------
                        _actionTile(
                          title: 'Alergias',
                          icon: Icons.warning,
                          color: AppColors.allergyAction,
                          loading: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientAllergiesScreen(
                                  patientId: patient!.id,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // ---------- Citas ----------
                        _actionTile(
                          title: hasAppointments ? 'Ver citas' : 'Crear cita',
                          icon: Icons.event,
                          color: AppColors.appointmentAction,
                          loading: loadingAppointments,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => hasAppointments
                                    ? ViewAppointmentsScreen(
                                        patientId: patient!.id,
                                      )
                                    : CreateAppointmentScreen(
                                        patientId: patient!.id,
                                      ),
                              ),
                            );
                            _checkAppointments();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Estado enfermedad ----------
  // Muestra la etapa de al enfermedad del paciente en un chip
  Widget _statusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.caregiverCardLigth,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        patient!.diseaseStage?.name ?? 'Sin estado',
        style: const TextStyle(
          color: AppColors.caregiverAppBar,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 
  Widget _infoCard(String title, String? value, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.caregiverCardLigth, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.caregiverAppBar),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(
                  value ?? 'No especificado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required IconData icon,
    required Color color,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              loading
                  ? SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: color,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(icon, color: color),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
