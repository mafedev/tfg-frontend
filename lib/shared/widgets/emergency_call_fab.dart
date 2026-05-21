import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';

class EmergencyCallFAB extends StatelessWidget {
  const EmergencyCallFAB({super.key});

  static const platform = MethodChannel('android_permission_service');

  // Normaliza el número de teléfono removiendo caracteres especiales
  String _normalizePhoneNumber(String phone) {
    // Remueve espacios, guiones, paréntesis y otros caracteres especiales
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  Future<void> _callCaregiver(BuildContext context) async {
    try {
      final storage = SecureStorageService();

      final phones = await storage.getCaregiverPhones();

      if (phones.isEmpty) {
        AppSnackBar.showError(
          context, 
          'No hay cuidadores disponibles. Asegúrate de estar vinculado a un cuidador.'
        );
        return;
      }

      // Toma el primer cuidador y normaliza el número
      final rawPhone = phones.first;
      final phone = _normalizePhoneNumber(rawPhone);

      if (phone.isEmpty) {
        AppSnackBar.showError(context, 'Número de teléfono inválido');
        return;
      }

      final bool success = await platform.invokeMethod<bool>(
        'makeCall',
        {'phoneNumber': phone},
      ) ?? false;

      if (success) {
        AppSnackBar.showSuccess(context, 'Llamada iniciada');
      } else {
        AppSnackBar.showError(context, 'No se pudo iniciar la llamada');
      }
    } on PlatformException catch (e) {
      AppSnackBar.showError(context, 'Error: ${e.message}');
    } catch (e) {
      AppSnackBar.showError(context, 'Error iniciando llamada: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "emergencyCall",
      backgroundColor: Colors.red,
      onPressed: () => _callCaregiver(context),
      child: const Icon(Icons.phone, color: Colors.white),
    );
  }
}

