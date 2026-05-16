import 'package:flutter/material.dart';
import 'package:tfg_frontend/shared/enums/medication/prescription_tracking_status.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import '../../data/prescription_tracking_service.dart';

class PrescriptionTrackingScreen extends StatefulWidget {
  final int patientId;

  const PrescriptionTrackingScreen({super.key, required this.patientId});

  @override
  State<PrescriptionTrackingScreen> createState() => _PrescriptionTrackingScreenState();
}

class _PrescriptionTrackingScreenState extends State<PrescriptionTrackingScreen> {
  final PrescriptionTrackingService _service = PrescriptionTrackingService();

  bool _loading = true; // maneja el círculo de carga
  List<PrescriptionTracking> _trackingList = []; // lista local con el tracking
  DateTime _selectedDate = DateTime.now(); // fecha seleccionada para mostrar el tracking

  @override
  void initState() {
    super.initState();
    _loadTracking(); // al iniciar, carga el tracking de hoy para el paciente
  }

  // ----------- Lógica de carga y toggle -----------
  Future<void> _loadTracking() async {
    setState(() => _loading = true);// al inicio pone cargar a true para mostrar el circulo de carga
    
    try {
      final result = await _service.getPrescriptionTracking(widget.patientId, _selectedDate);

      setState(() {
        _trackingList = result;
      });
    } catch (e) {
      AppSnackBar.showError(context, 'Error cargando tracking');
    } finally {
      setState(() => _loading = false); // luego de intentarlo, sin importar el resultado, pone cargar a false para ocultar el circulo de carga
    }
  }

  TrackingStatus _parseStatus(String status) {
    return TrackingStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TrackingStatus.PENDING,
    );
  }

  bool _isTaken(String status) {
    return _parseStatus(status) == TrackingStatus.TAKEN;
  }

  Future<void> _toggleTracking(PrescriptionTracking med, PrescriptionTrackingTime time) async {
    final oldStatus = time.status;
    final newStatus = _parseStatus(oldStatus) == TrackingStatus.TAKEN
        ? TrackingStatus.PENDING.name
        : TrackingStatus.TAKEN.name;

    setState(() {
      med.times = med.times.map((t) {
        if (t.scheduledTime == time.scheduledTime) {
          return PrescriptionTrackingTime(
            scheduledTime: t.scheduledTime,
            status: newStatus,
          );
        }
        return t;
      }).toList();
    });

    try {
      await _service.toggleTracking(
        prescriptionId: med.prescriptionId,
        scheduledTime: time.scheduledTime,
      );
    } catch (e) {
      setState(() {
        med.times = med.times.map((t) {
          if (t.scheduledTime == time.scheduledTime) {
            return PrescriptionTrackingTime(
              scheduledTime: t.scheduledTime,
              status: oldStatus,
            );
          }
          return t;
        }).toList();
      });

      AppSnackBar.showError(context, 'Error actualizando el estado');
    }
  }

  // ----------- Formateo de hora -----------
  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    // si está cargando, muestra el círculo de carga
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.caregiverBackground,
        appBar: AppLogoAppBar(title: 'Tomas de hoy', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    // si hay tomas para hoy
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,
      appBar: AppLogoAppBar(title: 'Tomas de hoy', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // -------- Selector de fecha ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined),
                  color: AppColors.caregiverPrimary,
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadTracking();
                    }
                  },
                ),

                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.caregiverPrimary,
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 10),

            // -------- Lista de medicamentos --------
            Expanded(
              child: _trackingList.isEmpty
                  ? const Center(child: Text('No hay tomas programadas'))
                  : ListView.builder(
                      itemCount: _trackingList.length, // el número de medicamentos a mostrar es el largo de la lista de tracking
                      // para cada medicamento, construye una tarjeta con la info
                      itemBuilder: (context, index) {
                        final med = _trackingList[index];

                    // -------- Tarjeta ----------
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ExpansionTile(
                            initiallyExpanded: index == 0,
                            iconColor: AppColors.caregiverPrimary,
                            collapsedIconColor: AppColors.caregiverPrimary,

                            // -------- Medicamento nombre --------
                            title: Text(
                              med.medicationName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.caregiverPrimary,
                              ),
                            ),

                            // -------- Dosis --------
                            subtitle: med.dose.isNotEmpty
                                ? Text(
                                    'Dosis: ${med.dose}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  )
                                : null,

                            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                            children: [
                              if (med.times.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Sin tomas programadas'),
                                ),

                              ...med.times.map((t) {
                                final isTaken = _isTaken(t.status);

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isTaken
                                        ? AppColors.confirm.withOpacity(0.12)
                                        : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Text(
                                          _formatTime(t.scheduledTime),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isTaken
                                              ? AppColors.confirm
                                              : AppColors.caregiverPrimary,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          t.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),

                                      Checkbox(
                                        value: isTaken,
                                        activeColor:
                                            AppColors.caregiverPrimary,
                                        onChanged: (_) =>
                                            _toggleTracking(med, t),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
