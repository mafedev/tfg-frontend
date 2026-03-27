import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/patients_routine/create_routine_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/services/caregiver_routine_service.dart';

class ViewRoutineScreen extends StatefulWidget {
  final int patientId; // id del paciente cuya rutina se va a ver

  const ViewRoutineScreen({super.key, required this.patientId});

  @override
  State<ViewRoutineScreen> createState() => _ViewRoutineScreenState();
}

class _ViewRoutineScreenState extends State<ViewRoutineScreen> {
  // Servicio para obtener y manipular la rutina
  final RoutineService _routineService = RoutineService();

  Map<String, dynamic>? routine; // contiene la rutina obtenida
  Map<String, dynamic>? tracking; // contiene el tracking obtenido
  bool loading = true; // indica si se está cargando la rutina

  // Estados de la rutina
  bool breakfastDone = false;
  bool lunchDone = false;
  bool dinnerDone = false;
  bool bathDone = false;
  bool hydrationDone = false;

  // Cuando se inicia la pantalla, carga la rutina
  @override
  void initState() {
    super.initState();
    _loadRoutine();
    _loadTracking();
  }

  // -------------------- Carga rutina --------------------
  Future<void> _loadRoutine() async {
    try {
      routine = await _routineService.getRoutine(widget.patientId); // obtiene la rutina
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cargar rutina')));
    } finally {
      setState(() => loading = false); // indica que ya no está cargando
    }
  }

  // -------------------- Elimina la rutina --------------------
  Future<void> _deleteRoutine() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: const Text('¿Seguro que quieres eliminar esta rutina?'),
        // Dependiendo de la opción elegida, devuelve true o false
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return; // si cancela, no hace nada

    try {
      await _routineService.deleteRoutine(widget.patientId); // llama al DELETE del backend
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rutina eliminada')));
      setState(() => routine = null); // actualiza estado para reflejar eliminación
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar rutina: $e')));
    }
  }

  // -------------------- Carga tracking --------------------
  Future<void> _loadTracking() async {
    try {
      tracking = await _routineService.getTodayTracking(widget.patientId);

      // Actualiza los estados de la rutina según el tracking
      setState(() {
        breakfastDone = tracking?['breakfastDone'] ?? false;
        lunchDone = tracking?['lunchDone'] ?? false;
        dinnerDone = tracking?['dinnerDone'] ?? false;
        bathDone = tracking?['bathDone'] ?? false;
        hydrationDone = tracking?['hydrationDone'] ?? false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar tracking: $e')));
    }
  }

  // -------------------- Marcar como hecho --------------------
  // Desayuno
  Future<void> _markBreakfast() async {
    await _routineService.markBreakfast(widget.patientId);
    setState(() => breakfastDone = true);
  }

  // Almuerzo
  Future<void> _markLunch() async {
    await _routineService.markLunch(widget.patientId);
    setState(() => lunchDone = true);
  }

  // Cena
  Future<void> _markDinner() async {
    await _routineService.markDinner(widget.patientId);
    setState(() => dinnerDone = true);
  }

  // Baño
  Future<void> _markBath() async {
    await _routineService.markBath(widget.patientId);
    setState(() => bathDone = true);
  }

  // Hidratación
  Future<void> _markHydration() async {
    await _routineService.markHydration(widget.patientId);
    setState(() => hydrationDone = true);
  }

  // -------------------- Checkbox item --------------------
  Widget _trackingItem(String label, bool value, Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Checkbox(value: value, onChanged: (_) => onTap()),
        ],
      ),
    );
  }

  // -------------------- Widget para el título de cada sección --------------------
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.caregiverPrimary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // -------------------- Card --------------------
  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // -------------------- Ítem de texto de la rutina --------------------
  Widget _routineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // -------------------- Formatea hh:mm:ss -> hh:mm --------------------
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '--:--';
    // divide por ":" y toma solo hora y minuto
    final parts = time.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  // -------------------- Construye la pantalla --------------------
  @override
  Widget build(BuildContext context) {
    // muestra un indicador de carga mientras se obtiene la rutina
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.caregiverAppBar),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppLogoAppBar(title: 'Rutina', backgroundColor: AppColors.caregiverAppBar),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: routine == null
            ? const Center(child: Text('No hay rutina asignada'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ---------- Muestra los horarios de la rutina ----------
                children: [
                  // ----------- COMIDAS -----------
                  _sectionCard(
                    children: [
                      _sectionTitle('Comidas', Icons.restaurant),
                      const SizedBox(height: 12),

                      _trackingItem(
                        'Desayuno - ${formatTime(routine!['breakfastTime'])}',
                        tracking?['breakfastDone'] ?? false,
                        _markBreakfast,
                      ),

                      _trackingItem(
                        'Almuerzo - ${formatTime(routine!['lunchTime'])}',
                        tracking?['lunchDone'] ?? false,
                        _markLunch,
                      ),

                      _trackingItem(
                        'Cena - ${formatTime(routine!['dinnerTime'])}',
                        tracking?['dinnerDone'] ?? false,
                        _markDinner,
                      ),
                    ],
                  ),

                  // ----------- HIDRATACIÓN -----------
                  _sectionCard(
                    children: [
                      _sectionTitle('Hidratación', Icons.water_drop),
                      const SizedBox(height: 12),

                      _trackingItem(
                        'Hidratación realizada',
                        tracking?['hydrationDone'] ?? false,
                        _markHydration,
                      ),
                    ],
                  ),

                  // ----------- ASEO -----------
                  _sectionCard(
                    children: [
                      _sectionTitle('Aseo', Icons.bathtub),
                      const SizedBox(height: 12),

                      _trackingItem(
                        'Baño - ${formatTime(routine!['bathTime'])}',
                        tracking?['bathDone'] ?? false,
                        _markBath,
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // ---------- Botón para editar la rutina ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caregiverPrimary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        // Navega a la pantalla de edición
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateRoutineScreen(
                              patientId: widget.patientId,
                              isEdit: true,
                            ),
                          ),
                        );
                        // Recarga la rutina después de editar
                        _loadRoutine();
                      },
                      child: const Text('Editar rutina'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---------- Botón para eliminar la rutina ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.delete,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _deleteRoutine,
                      child: const Text('Eliminar rutina'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
