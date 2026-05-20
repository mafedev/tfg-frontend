import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/data/auth_service.dart';
import 'package:tfg_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:tfg_frontend/features/profile/data/profile_service.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String username = '';
  String email = '';
  String phone = '';

  bool loading = true;

  final TextEditingController _currentPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await _profileService.getMyProfile();

      setState(() {
        username = data['username'] ?? '';
        email = data['email'] ?? '';
        phone = data['phone'] ?? '';
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _updateProfile() async {
    await _profileService.updateMyProfile(
      username: username,
      email: email,
      phone: phone,
    );
  }

  Future<void> _changePassword() async {
    if (_newPass.text != _confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    await _profileService.changePassword(
      currentPassword: _currentPass.text,
      newPassword: _newPass.text,
    );

    _currentPass.clear();
    _newPass.clear();
    _confirmPass.clear();

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña actualizada')),
    );
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

  void _editField({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                onSave(controller.text);

                await _updateProfile();

                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _openChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
              ),
              TextField(
                controller: _newPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
              ),
              TextField(
                controller: _confirmPass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Nombre de usuario'),
                    subtitle: Text(username),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(
                      title: 'Username',
                      currentValue: username,
                      onSave: (val) => username = val,
                    ),
                  ),

                  const Divider(height: 0),

                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(email),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(
                      title: 'Email',
                      currentValue: email,
                      onSave: (val) => email = val,
                    ),
                  ),

                  const Divider(height: 0),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Teléfono'),
                    subtitle: Text(phone),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editField(
                      title: 'Teléfono',
                      currentValue: phone,
                      onSave: (val) => phone = val,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Cambiar contraseña"),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openChangePasswordDialog,
            ),

            const Spacer(),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión'),
                onTap: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}