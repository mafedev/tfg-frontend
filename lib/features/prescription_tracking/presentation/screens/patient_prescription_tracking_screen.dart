import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/prescription_tracking/data/prescription_tracking_service.dart';
import 'package:tfg_frontend/shared/models/prescription_tracking.dart';

class PatientPrescriptionTrackingScreen extends StatefulWidget {
  const PatientPrescriptionTrackingScreen({super.key});

  @override
  State<PatientPrescriptionTrackingScreen> createState() => _PatientPrescriptionTrackingScreenState();
}

class _PatientPrescriptionTrackingScreenState extends State<PatientPrescriptionTrackingScreen> {
  final PrescriptionTrackingService _service = PrescriptionTrackingService();

  List<PrescriptionTracking> _tracking = []; // lista del seguimiento de medicamentos
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Carga el seguimiento de medicamentos para hoy
  Future<void> _load() async {
    try {
      final data = await _service.getMyPrescriptionTracking(DateTime.now());

      setState(() {
        _tracking = data; // actualiza la lista con la información que devuelve
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error cargando';
      });
    }
  }

  // Formatea la hora como 14:30
  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescripciones')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : _tracking.isEmpty
          ? const Center(child: Text('Sin prescripciones'))
          : ListView.builder(
              itemCount: _tracking.length,
              itemBuilder: (context, i) {
                final med = _tracking[i];

                return ListTile(
                  title: Text(med.medicationName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dosis: ${med.dose}'),
                      ...med.times.map(
                        (t) => Text(
                          '${_formatTime(t.scheduledTime)} - ${t.status}',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
