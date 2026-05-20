import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/data/auth_service.dart';
import 'package:tfg_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  String username = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final savedUsername = await _storage.getUsername();

    setState(() {
      username = savedUsername ?? 'Cuidador';
    });
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,

      appBar: const AppLogoAppBar(
        title: 'Perfil',
        backgroundColor: AppColors.caregiverAppBar,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.caregiverAccent.withOpacity(.2),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.caregiverAccent,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                trailing: const Icon(Icons.chevron_right),

                onTap: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Cerrar sesión'),
                        content: const Text('¿Deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancelar'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Salir'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    _logout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
