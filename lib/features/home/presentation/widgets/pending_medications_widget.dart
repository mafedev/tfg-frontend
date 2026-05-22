import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class PendingMedicationsWidget extends StatelessWidget {
  final List<dynamic> pending;

  const PendingMedicationsWidget({super.key, required this.pending});

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No hay tomas pendientes')),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pending.length,
        itemBuilder: (context, index) {
          final p = pending[index];

          final medication = p['medicationName'] ?? 'Medicamento';
          final patient = p['patientName'] ?? 'Paciente';
          final time = _formatTime(p['scheduledTime']);

          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dangerCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.alert),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        patient,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  medication,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  'Hora: $time',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '--:--';

    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}
