import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentCalendarWidget extends StatelessWidget {
  final List<DateTime> appointmentDays;

  const AppointmentCalendarWidget({super.key, required this.appointmentDays});

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
        padding: const EdgeInsets.all(10),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: DateTime.now(),
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
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
