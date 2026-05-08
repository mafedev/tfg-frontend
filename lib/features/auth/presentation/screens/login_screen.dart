import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/data/auth_service.dart';
import 'package:tfg_frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:tfg_frontend/features/navigation/navbar_caregiver.dart';
import 'package:tfg_frontend/features/navigation/navbar_patient.dart';
import 'package:tfg_frontend/core/services/secure_storage_service.dart';
import 'package:tfg_frontend/shared/enums/user/user_role.dart';
import 'package:tfg_frontend/shared/dtos/user/login_response.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // clave para acceder al estado del Form (validación, save, reset)
  final emailController = TextEditingController(); // controlador para el campo de correo (leer/limpiar/escuchar texto)
  final passwordController = TextEditingController(); // controlador para el campo de contraseña
  bool _obscurePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.caregiverSecondary,
      body: SafeArea( // Evita que el contenido quede detrás de cosas del sistema
        child: Center(
          child: Padding(
            // Espacio alrededor de la tarjeta
            padding: const EdgeInsets.all(20),
            child: Card(
              color: AppColors.caregiverBackground,
              shadowColor: AppColors.caregiverPrimary.withOpacity(0.15),

              // Tarjeta para el formulario
              elevation: 4, // Sombra
              shape: RoundedRectangleBorder(
                // Bordes redondeados
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                // ----------- Formulario -----------
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
                        borderSide: BorderSide(
                          color: AppColors.caregiverSecondary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.caregiverSecondary,
                        ),
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
                    key: _formKey, // Clave del formulario
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // ocupa solo lo necesario
                      crossAxisAlignment: CrossAxisAlignment.stretch, // estira hijos horizontalmente
                      children: [
                        const Text(
                          'Bienvenido', // título del formulario
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.caregiverPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),
                        // ----------- Correo -----------
                        TextFormField(
                          controller:
                              emailController, // conecta el TextFormField con emailController
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            hintText: 'tucorreo@ejemplo.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress, // Que el teclado sea de email
                        ),
                        const SizedBox(height: 12),
                        // ----------- Contraseña -----------
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Introduce tu contraseña'
                              : null, // validación simple, si está vacío devuelve el mensaje, si no, nulo (válido)
                          obscureText: _obscurePassword,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _login,
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
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ----------- Enlace a Signup -----------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // centra horizontalmente
                          children: [
                            const Text('¿No tienes una cuenta?'),
                            TextButton(
                              onPressed: () { // si se presiona el botón, navega a la pantalla de Signup
                                Navigator.of(context).push( // "push" añade una nueva pantalla a la pila de navegación
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Regístrate',
                                style: TextStyle(
                                  color: AppColors.caregiverPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  // ----------- Función de login -----------
  // Se llama cuando se presiona el botón de iniciar sesión

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {// valida el formulario
      final authService = AuthService();
      final LoginResponse? userData = await authService.login(
        emailController.text,
        passwordController.text,
      );

      // Si el login es exitoso, userData contendrá los datos del usuario
      if (userData != null) {
        final storage = SecureStorageService();
        await storage.saveToken(userData.token);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión correcto')), // muestra un mensaje de éxito
        );

        final String roleString = userData.role;
        final UserRole userRole = UserRole.values.firstWhere(
          (role) => role.name == roleString,
          orElse: () => UserRole.PATIENT,
        );
        
        if (userRole == UserRole.CAREGIVER) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => NavbarCaregiver()),
          );
        } else if (userRole == UserRole.PATIENT) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => NavbarPatient()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')), // muestra un mensaje de error
        );
      }
    }
  }
}
