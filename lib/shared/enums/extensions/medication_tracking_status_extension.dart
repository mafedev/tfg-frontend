import '../medication/prescription_tracking_status.dart';

extension MedicationTrackingStatusExtension on TrackingStatus {
  String get label {
    switch (this) {
      case TrackingStatus.PENDING:
        return 'Pendiente';
      case TrackingStatus.TAKEN:
        return 'Tomada';
    }
  }
}
