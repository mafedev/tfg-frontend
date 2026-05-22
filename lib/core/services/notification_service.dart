import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tfg_frontend/core/services/android_permission_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // inicializa las notificaciones
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings); // configuración de inicialización para Android

    await _notifications.initialize(settings); // inicializa el plugin de notificaciones con la configuración definida

    // Pedir permisos en tiempo de ejecución
    await AndroidPermissionService.requestPostNotificationPermission();
    await AndroidPermissionService.requestScheduleExactAlarmPermission();

    tz.initializeTimeZones();

    // se define el canal de notificaciones
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_channel', // id del canal
      'Recordatorio de Medicamentos', // nombre del canal
      description: 'Notificaciones para recordar la toma de medicamentos', // descripción del canal
      importance: Importance.max,  // importancia máxima para que las notificaciones se muestren de forma destacada
      enableVibration: true, // vibra
      enableLights: true, // enciende la luz de notificación
      playSound: true, // reproduce un sonido al recibir la notificación
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    // se crea el canal de noficicaciones
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  // Programa una notificación para una fecha y hora específicas
  Future<void> scheduleNotification({
    required int id, // id único para la notificación
    required DateTime dateTime, // fecha y hora para programar la notificación
    required String title, // título de la notificación
    required String body, // contenido de la notificación
  }) async {
    try {
      
      // se verifica que la fecha y hora programada no sea en el pasado, si es así, no se programa la notificación
      if (dateTime.isBefore(DateTime.now())) {
        return;
      }

      // se programa la notificación utilizando el servicio de alarmas de Android para garantizar que se muestre incluso si la aplicación está cerrada o en segundo plano
      await AndroidPermissionService.scheduleAlarm(
        id: id,
        dateTime: dateTime,
        title: title,
        body: body,
      );

      // si la programación con el servicio de alarmas falla, se utiliza flutter_local_notifications como fallback para programar la notificación
      await _scheduleWithFlutterNotifications(id, dateTime, title, body);
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  // Método privado para programar con flutter_local_notifications como fallback
  Future<void> _scheduleWithFlutterNotifications(
    int id,
    DateTime dateTime,
    String title,
    String body,
  ) async {
    try {
      // se programa la notificación utilizando flutter_local_notifications
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local), // convierte la fecha y hora a la zona horaria local
        
        // detalles de la notificación
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_channel', // id del canal
            'Recordatorio de Medicamentos', // nombre del canal
            channelDescription: 'Notificaciones para la toma de medicamentos', // descripción del canal
            importance: Importance.max,  // importancia máxima para que las notificaciones se muestren de forma destacada
            priority: Priority.high, // prioridad alta
            playSound: true, // reproduce el sonido de notificación
            sound: RawResourceAndroidNotificationSound('alarm_sound'),
            icon: '@drawable/notification_logo_blanco',
            enableVibration: true, // vibra
            enableLights: true,
          ),
        ),
        matchDateTimeComponents: null, // no se repite la notificación
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, 
      );
    } catch (e) {
      print('Error scheduling notification with flutter_local_notifications: $e');
    }
  }

  // Cancela una notificación programada utilizando el servicio de alarmas de Android y flutter_local_notifications como fallback
  Future<void> cancelNotification(int id) async {
    try {
      await AndroidPermissionService.cancelAlarm(id);
      await _notifications.cancel(id);
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }
}
