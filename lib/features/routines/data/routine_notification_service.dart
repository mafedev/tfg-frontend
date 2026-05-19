import 'package:tfg_frontend/core/services/notification_service.dart';
import 'package:tfg_frontend/shared/models/routine_item.dart';

class RoutineNotificationService {
  final NotificationService _notificationService = NotificationService();

  // ------------- Programar notificación para un item de rutina -------------
  Future<void> scheduleRoutineItem(RoutineItem item) async {
    if (item.time == null || item.time!.isEmpty){
      return; // Si no hay hora programada, no se programa la notificación
    }

    final now = DateTime.now(); // Obtiene la fecha y hora actual
    final parts = item.time!.split(":"); // Divide la hora en partes (hora y minuto)

    if (parts.length < 2) {
      return; // Si el formato de la hora no es correcto, no se programa la notificación
    }

    int hour;
    int minute;

    try {
      hour = int.parse(parts[0]); // Convierte la parte de la hora a entero
      minute = int.parse(parts[1]); // Convierte la parte de los minutos a entero
    } catch (_) {
      return; // por si el parse falla
    }

    // Crea un objeto DateTime para la hora programada, usando la fecha actual pero con la hora y minutos especificados
    DateTime scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    // Si la hora programada ya pasó para hoy, programa la notificación para el día siguiente
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Programa la notificación usando el servicio de notificaciones
    await _notificationService.scheduleNotification(
      id: item.id,
      dateTime: scheduled,
      title: "Rutina",
      body: "Es hora de ${item.name}",
    );
  }

  // ------------- Cancelar notificación para un item de rutina -------------
  Future<void> cancelRoutineItem(int itemId) async {
    await _notificationService.cancelNotification(itemId);
  }
}
