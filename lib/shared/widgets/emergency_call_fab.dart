import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallFAB extends StatelessWidget {
  const EmergencyCallFAB({super.key});

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
      final Uri uri = Uri(scheme: 'tel', path: phone);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
      } else {
        AppSnackBar.showError(context, 'No se pudo iniciar la llamada');
      }
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
