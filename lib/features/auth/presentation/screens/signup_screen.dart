import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/data/auth_service.dart';
import 'package:tfg_frontend/shared/enums/user/user_role.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  UserRole selectedRole = UserRole.CAREGIVER;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 520;

    return Scaffold(
      backgroundColor: AppColors.caregiverSecondary,
      appBar: AppBar(
        backgroundColor: AppColors.caregiverAppBar,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Registro',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                color: AppColors.caregiverBackground,
                elevation: 4,
                shadowColor: AppColors.caregiverPrimary.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.caregiverSecondary),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.caregiverSecondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.caregiverPrimary,
                            width: 2,
                          ),
                        ),
                        labelStyle: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Crea tu cuenta',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.caregiverPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Nombre
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              hintText: 'Ej: Juan',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Introduzca su nombre'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Correo
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              hintText: 'tucorreo@ejemplo.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Introduce tu correo' : null,
                          ),
                          const SizedBox(height: 12),

                          // Contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Introduzca una contraseña'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // Teléfono
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Introduzca su teléfono' : null,
                          ),
                          const SizedBox(height: 20),

                          // Selección de rol
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text('Selecciona una opción'),
                              ),
                              DropdownButton<UserRole>(
                                value: selectedRole,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: UserRole.values
                                    .map(
                                      (role) =>
                                          DropdownMenuItem(value: role, child: Text(role.name)),
                                    )
                                    .toList(),
                                onChanged: (role) =>
                                    setState(() => selectedRole = role!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Botón de registro
                          ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.caregiverPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Función de signup
  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authService = AuthService();
      final success = await authService.signup(
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole,
        phone: phoneController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear cuenta')),
        );
      }
    }
  }
}
