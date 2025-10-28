import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RutineService {
  final String baseUrl = 'http://10.0.2.2:8080/api/';

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<bool> saveRutine(TimeOfDay? _breakfastTime, TimeOfDay? _lunchTime, TimeOfDay? _dinnerTime, TimeOfDay? _bathTime, bool _enalbeHydrationReminders, int? _hydrationIntervalHours) async {
    final url = Uri.parse('$baseUrl/rutine');

    final body = jsonEncode({
      'breakfastTime': _formatTime(_breakfastTime),
      'lunchTime': _formatTime(_lunchTime),
      'dinnerTime': _formatTime(_dinnerTime),
      'bathTime': _formatTime(_bathTime),
      'enableHydration': _enalbeHydrationReminders,
      'hydrationIntervalHours': _hydrationIntervalHours,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Rutina guardada correctamente');
        return true;
      } else {
        print('Error al guardar rutina: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception al guardar rutina: $e');
      return false;
    }
  }
}