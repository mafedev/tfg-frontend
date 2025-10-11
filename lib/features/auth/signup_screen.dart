import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 520;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Crea tu cuenta',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            hintText: 'Tu nombre',
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Introduce tu nombre' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            hintText: 'tucorreo@ejemplo.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.isEmpty) ? 'Introduce tu correo' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Introduce una contraseña' : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Repetir contraseña',
                          ),
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? 'Repite la contraseña' : null,
                        ),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // TODO: procesar registro
                            }
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('Crear cuenta'),
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
}