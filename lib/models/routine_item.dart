class RoutineItem {
  final int id;
  final String name;
  final String time;
  final String type;

  RoutineItem({
    required this.id,
    required this.name,
    required this.time,
    required this.type,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
