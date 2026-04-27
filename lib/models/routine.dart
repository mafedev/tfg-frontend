import 'package:tfg_frontend/models/routine_item.dart';

class Routine {
  final int id;
  final List<RoutineItem> items;

  Routine({required this.id, required this.items});

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      items: (json['items'] as List)
          .map((e) => RoutineItem.fromJson(e))
          .toList(),
    );
  }
}
