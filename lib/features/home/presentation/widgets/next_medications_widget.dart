import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

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
      height: 140,
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
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFAF6FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFFDDD3F0)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.caregiverPrimary.withOpacity(.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.caregiverPrimary.withOpacity(.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 18, color: AppColors.caregiverPrimary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            patient,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B2E83),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      medication,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2F1F62),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.caregiverSecondary.withOpacity(.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppColors.caregiverPrimary),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.caregiverPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.caregiverAccent.withOpacity(.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'PENDIENTE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.caregiverPrimary,
                            ),
                          ),
                        ),
                      ],
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
