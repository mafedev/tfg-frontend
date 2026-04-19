class MedicationResponse {
  final int id;
  final String name;
  final String? description;
  final String type;

  MedicationResponse({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });

  factory MedicationResponse.fromJson(Map<String, dynamic> json) {
    return MedicationResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
    );
  }
}
