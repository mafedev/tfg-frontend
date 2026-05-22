import 'package:flutter/services.dart';

// Se encarga de gestionar los permisos para poder programar alarmas exactas
class AndroidPermissionService {
  static const _channel = MethodChannel('android_permission_service');

  // Verifica si el dispositivo permite programar alarmas exactas sin necesidad de pedir permiso
  static Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  // Abre la pantalla de ajustes para activar alarmas exactas
  static Future<void> openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod('openExactAlarmSettings');
    } on PlatformException {
      print('Error opening exact alarm settings');
    }
  }

  // Pide permiso para mostrar notificaciones
  static Future<void> requestPostNotificationPermission() async {
    try {
      await _channel.invokeMethod('requestPostNotificationPermission');
    } on PlatformException {
      print('Error requesting notification permission');
    }
  }

  // Pide permiso para SCHEDULE_EXACT_ALARM
  static Future<void> requestScheduleExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestScheduleExactAlarmPermission');
    } on PlatformException {
      print('Error requesting schedule exact alarm permission');
    }
  }

  // Programa una alarma usando AlarmManager
  static Future<void> scheduleAlarm({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    try {
      final timeMillis = dateTime.millisecondsSinceEpoch;
      await _channel.invokeMethod('scheduleAlarm', {
        'id': id,
        'timeMillis': timeMillis,
        'title': title,
        'body': body,
      });
    } on PlatformException catch (e) {
      print('Error scheduling alarm: ${e.message}');
    }
  }

  // Cancela una alarma programada usando su id
  static Future<void> cancelAlarm(int id) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {'id': id});
    } on PlatformException {
      print('Error cancelling alarm');
    }
  }
}
