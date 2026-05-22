import '../medication/prescription_status.dart';

extension DoseUnitExtension on DoseUnit {
  String get label {
    switch (this) {
      case DoseUnit.MG:
        return 'mg';
      case DoseUnit.ML:
        return 'ml';
      case DoseUnit.CAPSULE:
        return 'Cápsula';
      case DoseUnit.TABLET:
        return 'Tableta';
      case DoseUnit.DROP:
        return 'Gota';
      case DoseUnit.INHALATION:
        return 'Inhalación';
      case DoseUnit.PATCH:
        return 'Parche';
    }
  }
}
