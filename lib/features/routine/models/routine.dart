class Routine {
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;
  final String bathTime;
  final bool enableHydration;
  final int? waterReminder; // puede ser nulo

  // Constructor
  Routine({
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.bathTime,
    required this.enableHydration,
    this.waterReminder,
  });

  // ----------- Crea un objeto Routine a partir de un JSON -----------
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      breakfastTime: json['breakfastTime'],
      lunchTime: json['lunchTime'],
      dinnerTime: json['dinnerTime'],
      bathTime: json['bathTime'],
      enableHydration: json['enableHydration'],
      waterReminder: json['waterReminder'],
    );
  }
}
