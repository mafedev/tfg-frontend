import 'package:tfg_frontend/core/services/notification_service.dart';
import 'package:tfg_frontend/shared/models/routine_item.dart';

class RoutineNotificationService {
  final NotificationService _notificationService = NotificationService();

  Future<void> scheduleRoutineItem(RoutineItem item) async {
    if (item.time == null || item.time!.isEmpty) return;

    final now = DateTime.now();
    final parts = item.time!.split(":");

    if (parts.length < 2) return;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _notificationService.scheduleNotification(
      id: item.id,
      dateTime: scheduled,
      title: "Rutina",
      body: "Es hora de ${item.name}",
    );
  }

  Future<void> cancelRoutineItem(int itemId) async {
    await _notificationService.cancelNotification(itemId);
  }
}