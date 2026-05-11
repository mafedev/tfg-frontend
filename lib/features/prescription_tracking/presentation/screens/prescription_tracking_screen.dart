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
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(
                        const Duration(days: 1),
                      );
                    });
                    _loadTracking();
                  },
                ),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(
                        const Duration(days: 1),
                      );
                    });
                    _loadTracking();
                  },
                ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nombre del medicamento
                                Text(
                                  med.medicationName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),

                                if (med.dose.isNotEmpty) Text('Dosis: ${med.dose}'),

                                const SizedBox(height: 12),

                                if (med.times.isEmpty) const Text('Sin tomas para hoy'),

                                if (med.times.isNotEmpty)
                                  Column(
                                    children: med.times.map((t) {
                                      final isTaken = _isTaken(t.status);

                                      return Row(
                                        children: [
                                          // muestra la hora
                                          Expanded(child: Text(_formatTime(t.scheduledTime))),
                                          // Texto según el toggle
                                          Text(
                                            t.status,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          // agrega el checkbox para marcar si lo ha tomado o no
                                          Checkbox(
                                            value: isTaken, // el valor del checkbox depende de si la toma ha sido marcada como tomada o no
                                            onChanged: (_) {
                                              _toggleTracking(med, t); // al cambiar el estado del checkbox, llama a la función de toggle para actualizar el estado tanto en la interfaz como en el backend
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(), // convierte la lista de tomas a una lista de widgets para mostrar en la interfaz
                                  ),
                              ],
                            ),
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
