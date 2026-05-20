import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/data/auth_service.dart';
import 'package:tfg_frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:tfg_frontend/features/profile/data/profile_service.dart';
import 'package:tfg_frontend/shared/widgets/app_logo_appbar.dart';
import 'package:tfg_frontend/shared/widgets/app_primary_button.dart';
import 'package:tfg_frontend/shared/widgets/app_primary_icon_button.dart';
import 'package:tfg_frontend/shared/widgets/app_snack_bar.dart';

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
  bool _obscureCurrentPass = true;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

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
      AppSnackBar.showError(context, 'Las contraseñas no coinciden');
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

    AppSnackBar.showSuccess(context, 'Contraseña actualizada');
  }

  String _capitalizeName(String value) {
    return value
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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
            SizedBox(
              width: 120,
              child: AppPrimaryButton(
                text: 'Guardar',
                onPressed: () async {
                  onSave(controller.text);

                  await _updateProfile();

                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openChangePasswordDialog() {
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Cambiar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _currentPass,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          dialogSetState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: _newPass,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          dialogSetState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: _confirmPass,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          dialogSetState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                SizedBox(
                  width: 120,
                  child: AppPrimaryButton(
                    text: 'Guardar',
                    onPressed: _changePassword,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = _capitalizeName(username);

    return Scaffold(
      backgroundColor: AppColors.caregiverBackground,

      appBar: const AppLogoAppBar(
        title: 'Perfil',
        backgroundColor: AppColors.caregiverAppBar,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.caregiverAppBar.withOpacity(.12),
              child: Icon(
                Icons.person,
                size: 52,
                color: AppColors.caregiverAppBar,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              displayName.isEmpty ? 'Cuidador' : displayName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),

            const SizedBox(height: 32),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.person,
                      color: AppColors.caregiverAppBar,
                    ),
                    title: const Text('Nombre de usuario'),
                    subtitle: Text(displayName),
                    trailing: Icon(
                      Icons.edit,
                      color: AppColors.caregiverPrimary,
                    ),
                    onTap: () => _editField(
                      title: 'Nombre de usuario',
                      currentValue: username,
                      onSave: (val) => username = val,
                    ),
                  ),

                  const Divider(height: 0),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.email,
                      color: AppColors.caregiverAppBar,
                    ),
                    title: const Text('Email'),
                    subtitle: Text(email),
                    trailing: Icon(
                      Icons.edit,
                      color: AppColors.caregiverPrimary,
                    ),
                    onTap: () => _editField(
                      title: 'Email',
                      currentValue: email,
                      onSave: (val) => email = val,
                    ),
                  ),

                  const Divider(height: 0),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Icon(
                      Icons.phone,
                      color: AppColors.caregiverAppBar,
                    ),
                    title: const Text('Teléfono'),
                    subtitle: Text(phone),
                    trailing: Icon(
                      Icons.edit,
                      color: AppColors.caregiverPrimary,
                    ),
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(Icons.lock, color: AppColors.caregiverAppBar),
                title: const Text('Cambiar contraseña'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openChangePasswordDialog,
              ),
            ),

            const Spacer(),

            AppPrimaryIconButton(
              text: 'Cerrar sesión',
              icon: Icons.logout,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
