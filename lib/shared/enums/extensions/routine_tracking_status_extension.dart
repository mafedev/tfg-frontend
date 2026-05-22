import '../routine/routine_tracking_status.dart';

extension RoutineTrackingStatusExtension on TrackingStatus {
  String get label {
    switch (this) {
      case TrackingStatus.PENDING:
        return 'Pendiente';
      case TrackingStatus.DONE:
        return 'Completada';
      case TrackingStatus.SKIPPED:
        return 'Omitida';
    }
  }
}
