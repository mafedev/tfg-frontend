import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/tts_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/enums/routine/routine_tracking_status.dart';
import 'package:tfg_frontend/shared/models/routine.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/emergency_call_fab.dart';

class PatientRoutineScreen extends StatefulWidget {
  const PatientRoutineScreen({super.key});

  @override
  State<PatientRoutineScreen> createState() => _PatientRoutineScreenState();
}

class _PatientRoutineScreenState extends State<PatientRoutineScreen> {
  final RoutineService _service = RoutineService();
  final TtsService _tts = TtsService();

  Routine? routine; // almacena la rutina
  bool loading = true; // es para mostrar si la pantalla está cargando

  String? error;
  List<Map<String, dynamic>> tracking = [];

  // Carga la rutina cuando se inicializa
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final routineResult = await _service.getMyRoutine();

      if (routineResult == null) {
        setState(() {
          loading = false;
          error = 'No tienes rutina asignada';
        });
        return;
      }

      final trackingResult = await _service.getMyTracking(DateTime.now());

      setState(() {
        routine = routineResult;
        tracking = trackingResult;
        loading = false;
        error = null;
      });

      if (routineResult.items.isNotEmpty) {
        _readRoutine();
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error al cargar la rutina';
      });
    }
  }

  TrackingStatus _getStatus(int itemId) {
    final match = tracking.where((t) => t['itemId'] == itemId).toList();

    if (match.isEmpty) {
      return TrackingStatus.PENDING;
    }

    final status = match.first['status'];

    switch (status) {
      case 'DONE':
        return TrackingStatus.DONE;
      case 'SKIPPED':
        return TrackingStatus.SKIPPED;
      default:
        return TrackingStatus.PENDING;
    }
  }

  Color _statusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.DONE:
        return Colors.green;
      case TrackingStatus.SKIPPED:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.DONE:
        return Icons.check_circle;
      case TrackingStatus.SKIPPED:
        return Icons.close;
      default:
        return Icons.schedule;
    }
  }

  String _statusText(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.DONE:
        return 'HECHO';
      case TrackingStatus.SKIPPED:
        return 'OMITIDO';
      default:
        return 'PENDIENTE';
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) {
      return '--:--';
    }

    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  Future<void> _readRoutine() async {
    if (routine == null || routine!.items.isEmpty) {
      await _tts.speak('No tienes rutina asignada para hoy.');
      return;
    }

    final buffer = StringBuffer();
    buffer.write('Esta es tu rutina de hoy. ');

    for (final item in routine!.items) {
      final status = _getStatus(item.id);
      final statusText = status == TrackingStatus.DONE
          ? 'hecho'
          : status == TrackingStatus.SKIPPED
          ? 'omitido'
          : 'pendiente';
      final time = item.time == null || item.time!.isEmpty
          ? 'sin hora definida'
          : '${item.time}';

      buffer.write('Actividad: ${item.name}. ');
      buffer.write('Hora: $time. ');
      buffer.write('Estado: $statusText. ');
    }

    await _tts.speak(buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.patientBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mi rutina',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    if (routine == null) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mi rutina',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: const Center(
          child: Text(
            'No tienes rutina asignada',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    if (routine!.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.patientBackground,
        appBar: const AppLogoAppBar(
          title: 'Mi rutina',
          backgroundColor: AppColors.patientAppBar,
        ),
        body: const Center(
          child: Text(
            'No hay elementos en tu rutina',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: const EmergencyCallFAB(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.patientBackground,
      appBar: const AppLogoAppBar(
        title: 'Mi rutina',
        backgroundColor: AppColors.patientAppBar,
      ),
      floatingActionButton: const EmergencyCallFAB(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          const Text(
            'Tu rutina diaria',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _readRoutine,
            icon: const Icon(Icons.volume_up, size: 24),
            label: const Text(
              'Leer rutina en voz alta',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.patientPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 22),

          ...routine!.items.map((item) {
            final status = _getStatus(item.id);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(status),
                    size: 34,
                    color: _statusColor(status),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(item.time),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _statusText(status),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
