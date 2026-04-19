import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/notification_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/models/medication_tracking.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/main.dart';
import '../services/prescription_tracking_service.dart';

class PrescriptionTrackingScreen extends StatefulWidget {
  final int patientId;

  const PrescriptionTrackingScreen({super.key, required this.patientId});

  @override
  State<PrescriptionTrackingScreen> createState() => _PrescriptionTrackingScreenState();
}

class _PrescriptionTrackingScreenState extends State<PrescriptionTrackingScreen> {
  final PrescriptionTrackingService _service = PrescriptionTrackingService();

  bool _loading = true; // maneja el círculo de carga
  List<MedicationTracking> _trackingList = []; // lista local con el tracking
  DateTime _selectedDate = DateTime.now(); // fecha seleccionada para mostrar el tracking

  @override
  void initState() {
    super.initState();
    _loadTracking(); // al iniciar, carga el tracking de hoy para el paciente
  }

  // ----------- Lógica de carga y toggle -----------
  Future<void> _loadTracking() async {
    setState(() => _loading = true); // al inicio pone cargar a true para mostrar el circulo de carga
    
    try {
      final result = await _service.getMedicationTracking(widget.patientId, _selectedDate);
      
      setState(
        () => _trackingList = result // mapea el tracking obtenido a la lista de tracking local
            .map((json) => MedicationTracking.fromJson(json)) // convierte cada json a un objeto MedicationTracking
            .toList(), // y luego lo convierte a una lista
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar tracking: $e')));
    } finally {
      setState(() => _loading = false); // luego de intentarlo, sin importar el resultado, pone cargar a false para ocultar el circulo de carga
    }
  }

  // ----------- Lógica de toggle -----------
  // Esta función se llama cuando el usuario marca o desmarca una toma
  Future<void> _toggleTracking(MedicationTracking med, MedicationTrackingTime time) async {
    
    // al hacer click, primero actualiza el estado en la interfaz
    setState(() => time.taken = !time.taken);

    try {
      // luego hace la llamada al servicio para actualizar el estado en el backend
      await _service.toggleTracking(
        prescriptionId: med.prescriptionId,
        scheduledTime: time.scheduledTime,
      );
    } catch (e) {
      // si hay un error, deshace el cambio en la interfaz y muestra el error en pantalla
      setState(() => time.taken = !time.taken);
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
        body: const Center(child: CircularProgressIndicator(color: AppColors.caregiverAppBar)),
      );
    }

    // si no hay tomas, muestra el mensaje
    if (_trackingList.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppLogoAppBar(title: 'Tomas de hoy', backgroundColor: AppColors.caregiverAppBar),
        body: Column(
          children: [
            // -------- Selector de fecha ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                      });
                      _loadTracking();
                    },
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            ),

            const Expanded(child: Center(child: Text('No hay tomas programadas para hoy'))),
          ],
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
        child: ListView.builder(
          itemCount: _trackingList.length, // el número de medicamentos a mostrar es el largo de la lista de tracking
          
          // para cada medicamento, construye una tarjeta con la info
          itemBuilder: (context, index) {
            final med = _trackingList[index]; // obtiene el medicamento actual a mostrar

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

                    // Dosis
                    if (med.dose.isNotEmpty) Text('Dosis: ${med.dose}'),

                    const SizedBox(height: 12),

                    // Si no hay tomas
                    if (med.times.isEmpty) const Text('Sin tomas para hoy'),

                    // Si hay tomas
                    if (med.times.isNotEmpty)
                      Column(
                        children: med.times.map((t) { // para cada toma del medicamento, construye una fila con la hora y el checkbox
                          return Row(
                            children: [
                              // muestra la hora
                              Expanded(child: Text(_formatTime(t.scheduledTime))),
                              // Texto según el toggle
                              Text(
                                t.taken ? 'TAKEN' : 'PENDING',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // agrega el checkbox para marcar si lo ha tomado o no
                              Checkbox(
                                value: t.taken, // el valor del checkbox depende de si la toma ha sido marcada como tomada o no
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
