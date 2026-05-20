import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';

class AppointmentCalendarWidget extends StatelessWidget {
  final List<DateTime> appointmentDays;
  final Function(DateTime selectedDay) onDaySelected;

  const AppointmentCalendarWidget({
    super.key,
    required this.appointmentDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: DateTime.now(),
              onDaySelected: (selectedDay, focusedDay) {
                onDaySelected(selectedDay);
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2E83),
                ),
                formatButtonVisible: false,
                leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF7B3ED8)),
                rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF7B3ED8)),
              ),
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7B3ED8),
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFF1E6F7),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF7B3ED8),
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final hasAppointment = appointmentDays.any(
                    (d) =>
                        d.year == date.year &&
                        d.month == date.month &&
                        d.day == date.day,
                  );

                  if (!hasAppointment) {
                    return null;
                  }

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.caregiverPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.caregiverPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Día con cita programada',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
