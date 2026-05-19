class RoutineItem {
  final int id;
  String name;
  String? time;
  String type;

  RoutineItem({
    required this.id,
    required this.name,
    this.time,
    required this.type,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'],
      name: json['name'],
      time: json['time'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'time': time, 'type': type};
  }
}
