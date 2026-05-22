import '../medication/medication_type.dart';

extension MedicationTypeExtension on MedicationType {
  String get label {
    switch (this) {
      case MedicationType.TABLET:
        return 'Tableta';
      case MedicationType.COATED_TABLET:
        return 'Tableta recubierta';
      case MedicationType.EFFERVESCENT_TABLET:
        return 'Tableta efervescente';
      case MedicationType.SUBLINGUAL_TABLET:
        return 'Tableta sublingual';
      case MedicationType.CHEWABLE_TABLET:
        return 'Tableta masticable';
      case MedicationType.HARD_CAPSULE:
        return 'Cápsula dura';
      case MedicationType.SOFT_CAPSULE:
        return 'Cápsula blanda';
      case MedicationType.DRAGEE:
        return 'Dragee';
      case MedicationType.TABLET_FORM:
        return 'Forma de tableta';
      case MedicationType.PILL:
        return 'Pastilla';
      case MedicationType.POWDER:
        return 'Polvo';
      case MedicationType.GRANULES:
        return 'Gránulos';
      case MedicationType.SACHET:
        return 'Sobre';
      case MedicationType.SYRUP:
        return 'Jarabe';
      case MedicationType.ORAL_SOLUTION:
        return 'Solución oral';
      case MedicationType.ORAL_SUSPENSION:
        return 'Suspensión oral';
      case MedicationType.ORAL_EMULSION:
        return 'Emulsión oral';
      case MedicationType.ORAL_DROPS:
        return 'Gotas orales';
      case MedicationType.OPHTHALMIC_DROPS:
        return 'Gotas oftálmicas';
      case MedicationType.OTIC_DROPS:
        return 'Gotas óticas';
      case MedicationType.NASAL_DROPS:
        return 'Gotas nasales';
      case MedicationType.INTRAMUSCULAR_INJECTION:
        return 'Inyección intramuscular';
      case MedicationType.INTRAVENOUS_INJECTION:
        return 'Inyección intravenosa';
      case MedicationType.SUBCUTANEOUS_INJECTION:
        return 'Inyección subcutánea';
      case MedicationType.INTRAVENOUS_SOLUTION:
        return 'Solución intravenosa';
      case MedicationType.AMPOULE:
        return 'Ampolla';
      case MedicationType.VIAL:
        return 'Vial';
      case MedicationType.CREAM:
        return 'Crema';
      case MedicationType.OINTMENT:
        return 'Ungüento';
      case MedicationType.GEL:
        return 'Gel';
      case MedicationType.LOTION:
        return 'Loción';
      case MedicationType.FOAM:
        return 'Espuma';
      case MedicationType.SPRAY:
        return 'Spray';
      case MedicationType.AEROSOL:
        return 'Aerosol';
      case MedicationType.INHALER:
        return 'Inhalador';
      case MedicationType.NEBULIZER:
        return 'Nebulizador';
      case MedicationType.TRANSDERMAL_PATCH:
        return 'Parche transdérmico';
      case MedicationType.SUPPOSITORY:
        return 'Supositorio';
      case MedicationType.VAGINAL_OVULE:
        return 'Óvulo vaginal';
      case MedicationType.ENEMA:
        return 'Enema';
      case MedicationType.EYE_DROPS:
        return 'Gotas oculares';
      case MedicationType.MOUTHWASH:
        return 'Enjuague bucal';
      case MedicationType.IMPLANT:
        return 'Implante';
      case MedicationType.LYOPHILIZED:
        return 'Liofilizado';
    }
  }
}
