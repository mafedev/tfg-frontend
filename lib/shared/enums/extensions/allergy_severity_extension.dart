import '../allergies/allergies_severity.dart';

extension AllergySeverityExtension on AllergySeverity {
  String get label {
    switch (this) {
      case AllergySeverity.LOW:
        return 'Baja';
      case AllergySeverity.MODERATE:
        return 'Moderada';
      case AllergySeverity.HIGH:
        return 'Alta';
      case AllergySeverity.CRITICAL:
        return 'Crítica';
    }
  }
}
