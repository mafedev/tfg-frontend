class Routine {
  final String breakfastTime;
  final String lunchTime;
  final String dinnerTime;
  final String bathTime;
  final bool hydrationEnabled;
  final int? hydrationReminderHours; // puede ser nulo

  // Constructor
  Routine({
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.bathTime,
    required this.hydrationEnabled,
    this.hydrationReminderHours,
  });

  // ----------- Crea un objeto Routine a partir de un JSON -----------
  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      breakfastTime: json['breakfastTime'],
      lunchTime: json['lunchTime'],
      dinnerTime: json['dinnerTime'],
      bathTime: json['bathTime'],
      hydrationEnabled: json['hydrationEnabled'],
      hydrationReminderHours: json['hydrationReminderHours'],
    );
  }
}
