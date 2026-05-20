import 'package:flutter/material.dart';

class NextMedicationsWidget extends StatelessWidget {
  final List<dynamic> prescriptions;
  final PageController pageController;

  const NextMedicationsWidget({
    super.key,
    required this.prescriptions,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    if (prescriptions.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No hay medicaciones pendientes')),
      );
    }

    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: pageController,
        itemCount: prescriptions.length,
        padEnds: false,
        itemBuilder: (context, index) {
          final p = prescriptions[index];
          final medication = p['medicationName'] ?? 'Medicamento';
          final patient = p['patientName'] ?? 'Paciente';
          final time = _formatTime(p['scheduledTime']);

          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(width: 15),
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 5),
                        Expanded(child: Text(patient, overflow: TextOverflow.ellipsis)),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(.15),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Text(
                        'PENDIENTE',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) {
      return '--:--';
    }

    try {
      final dt = DateTime.parse(iso);

      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }
}
