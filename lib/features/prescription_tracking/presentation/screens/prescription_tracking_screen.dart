import 'package:flutter/material.dart';
import 'package:tfg_frontend/shared/enums/medication/prescription_tracking_status.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar tracking: $e')));
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

  String _toggleStatus(String status) {
    final parsed = _parseStatus(status);

    return parsed == TrackingStatus.TAKEN
        ? TrackingStatus.PENDING.name
        : TrackingStatus.TAKEN.name;
  }

  // ----------- Lógica de toggle -----------
  // Esta función se llama cuando el usuario marca o desmarca una toma
  Future<void> _toggleTracking(PrescriptionTracking med, PrescriptionTrackingTime time) async {
    final oldStatus = time.status;
    final newStatus = _toggleStatus(oldStatus);

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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
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
        backgroundColor: AppColors.background,
        appBar: AppLogoAppBar(title: 'Tomas de hoy', backgroundColor: AppColors.caregiverAppBar),
        body: const Center(child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    // si hay tomas para hoy
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  icon: const Icon(Icons.calendar_month),
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
                  ),
                ),

                const SizedBox(width: 48), // balance visual
              ],
            ),

            const SizedBox(height: 10),

            // Muestra la lista de medicamentos
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
                          margin: const EdgeInsets.symmetric(vertical: 8), // espacio entre las tarjetas
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // bordes redondeados
                          elevation: 3, // sombra
                          child: ExpansionTile(
                            initiallyExpanded: index == 0,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                            // -------- Medicamento nombre --------
                            title: Text(
                              med.medicationName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // -------- Dosis --------
                            subtitle: med.dose.isNotEmpty
                                ? Text('Dosis: ${med.dose}')
                                : null,

                            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),

                            children: [
                              if (med.times.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Sin tomas para hoy'),
                                ),

                              ...med.times.map((t) {
                                final isTaken = _isTaken(t.status);

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(_formatTime(t.scheduledTime)),
                                    ),
                                    Text(
                                      t.status,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isTaken,
                                      onChanged: (_) => _toggleTracking(med, t),
                                    ),
                                  ],
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
