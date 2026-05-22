import '../user/user_role.dart';

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.CAREGIVER:
        return 'Cuidador';
      case UserRole.PATIENT:
        return 'Paciente';
    }
  }
}
