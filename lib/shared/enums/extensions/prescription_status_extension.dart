import '../medication/prescription_status.dart';

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get label {
    switch (this) {
      case PrescriptionStatus.ACTIVE:
        return 'Activa';
      case PrescriptionStatus.SUSPENDED:
        return 'Suspendida';
      case PrescriptionStatus.COMPLETED:
        return 'Completada';
      case PrescriptionStatus.CANCELLED:
        return 'Cancelada';
    }
  }
}
