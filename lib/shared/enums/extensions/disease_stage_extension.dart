import '../user/patient/disease_stage.dart';

extension DiseaseStageExtension on DiseaseStage {
  String get label {
    switch (this) {
      case DiseaseStage.EARLY:
        return 'Temprana';
      case DiseaseStage.MODERATE:
        return 'Moderada';
      case DiseaseStage.ADVANCED:
        return 'Avanzada';
    }
  }
}
