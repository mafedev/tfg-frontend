import '../appointment/appointment_status.dart';

extension AppointmentStatusExtension on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.PENDING:
        return 'Pendiente';
      case AppointmentStatus.ATTENDED:
        return 'Atendida';
      case AppointmentStatus.MISSED:
        return 'No asistida';
      case AppointmentStatus.CANCELLED:
        return 'Cancelada';
    }
  }
}
