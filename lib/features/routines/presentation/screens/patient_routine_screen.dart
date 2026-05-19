import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/routines/data/caregiver_routine_service.dart';
import 'package:tfg_frontend/shared/enums/routine/routine_tracking_status.dart';
import 'package:tfg_frontend/shared/models/routine.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class PatientRoutineScreen extends StatefulWidget {
  const PatientRoutineScreen({super.key});

  @override
  State<PatientRoutineScreen> createState() => _PatientRoutineScreenState();
}

class _PatientRoutineScreenState extends State<PatientRoutineScreen> {
  final RoutineService _service = RoutineService();

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
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error al cargar la rutina';
      });
    }
  }

  TrackingStatus _getStatus(int itemId) {
    final match = tracking.where((t) => t['itemId'] == itemId).toList();

    if (match.isEmpty) return TrackingStatus.PENDING;

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
      case TrackingStatus.PENDING:
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
      case TrackingStatus.PENDING:
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
      case TrackingStatus.PENDING:
      default:
        return 'PENDIENTE';
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';

    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppLogoAppBar(title: 'Mi rutina', backgroundColor: AppColors.patientAppBar),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : routine == null
          ? const Center(child: Text('No tienes rutina asignada'))
          : routine!.items.isEmpty
          ? const Center(child: Text('No hay elementos en tu rutina'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Tu rutina diaria',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                ...routine!.items.map((item) {
                  final status = _getStatus(item.id);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(status), color: _statusColor(status)),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatTime(item.time)),

                            const SizedBox(height: 4),

                            Text(
                              _statusText(status),
                              style: TextStyle(
                                fontSize: 12,
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
