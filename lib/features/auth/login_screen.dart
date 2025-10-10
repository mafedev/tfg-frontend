// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/auth/signup_screen.dart';
import 'package:tfg_frontend/core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 420;

    return Scaffold(
      // Quitamos el backgroundColor para que se vea el fondo pintado
      body: CustomPaint(
        painter: DiagonalBackgroundPainter(), // Pinta el fondo con la diagonal
        child: SafeArea( // Evita que el contenido quede detrás de cosas del sistema
          child: Center( // Centra el contenido
            child: ConstrainedBox( // Limita el ancho máximo del contenido
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Card( // Tarjeta para el formulario
                  elevation: 4, // Sombra
                  shape: RoundedRectangleBorder( // Bordes redondeados
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding( // Padding interno de la tarjeta
                    padding: const EdgeInsets.all(20),
                    // Formulario
                    child: Form(
                      key: _formKey, // Clave del formulario
                      child: Column( // Columna para los campos y botones
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Bienvenido',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          
                          // Correo
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              hintText: 'tucorreo@ejemplo.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress, // Que el teclado sea de email
                          ),
                          const SizedBox(height: 12),

                          // Contraseña
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Introduce tu contraseña' : null,
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // TODO: login
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Iniciar sesión'),
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tienes una cuenta?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Regístrate'),
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
      ),
    );
  }
}

class DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Color superior izquierdo
    // ignore: deprecated_member_use
    paint.color = AppColors.primary.withOpacity(0.9);
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    // Color inferior derecho
    paint.color = AppColors.secondary.withOpacity(0.9);
    final path2 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
