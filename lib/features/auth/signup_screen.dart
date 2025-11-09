import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';
import 'package:tfg_frontend/features/auth/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave del formulario, para validación

  final nameController = TextEditingController(); // Controlador para el campo de nombre
  final emailController = TextEditingController(); // Controlador para el campo de correo
  final passwordController = TextEditingController(); // Controlador para el campo de contraseña
  String selectedValue = 'Cuidador';

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 520; // Ancho máximo para pantallas grandes

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registro')), // Barra superior con título
      body: SafeArea(
        child: Center(
          child: ConstrainedBox( // Limita el ancho máximo del contenido
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form( // Formulario de registro
                    key: _formKey, // Asocia la clave del formulario
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        /* NOMBRE */
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Introduzca su nombre',
                            hintText: 'Ej: Juan Pérez',
                          ),
                          // Validación del campo de nombre
                          validator: (v) => (v == null || v.isEmpty) // se asegura que no esté vacío
                              ? 'Introduzca su nombre' // mensaje de error si está vacío
                              : null,
                        ),

                        /* CORREO */
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Introduzca su correo',
                            hintText: 'tucorreo@ejemplo.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress, // Teclado específico para email
                          // Validación del campo de correo
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Introduce tu correo'
                              : null,
                        ),

                        /* CONTRASEÑA */ 
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Introduce una contraseña'
                              : null,
                        ),

                        
                        /* SELECCIÓN DE ROL */
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('Selecciona una opción'),
                          ),
                          DropdownButton<String>(
                            value: selectedValue,
                            underline: const SizedBox.shrink(), // quita la línea
                            isExpanded: true,
                            items: ['Cuidador', 'Paciente']
                                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) => setState(() => selectedValue = value!),
                          ),
                        ],
                      ),

                        /* BOTÓN DE REGISTRO */
                        ElevatedButton(
                          onPressed: () async { // Acción al pulsar el botón
                            if (_formKey.currentState?.validate() ?? false) { // si la clave del formulario es válida y no es nula
                              final authService = AuthService(); // instancia del servicio de autenticación
                              final success = await authService.signup( // llama al método de registro
                                // obtiene los valores de los controladores y los limpia de espacios
                                username: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                role: selectedValue.trim()
                              );

                              if (success) { // si el registro fue exitoso
                                ScaffoldMessenger.of(context).showSnackBar( // muestra un mensaje de éxito
                                  const SnackBar(
                                    content: Text(
                                      'Cuenta creada correctamente',
                                    ),
                                  ),
                                );
                                Navigator.pop(context); // vuelve a la pantalla anterior (login)
                              } else { // si hubo un error en el registro, muestra un mensaje de error
                                ScaffoldMessenger.of(context).showSnackBar( 
                                  const SnackBar(
                                    content: Text('Error al crear cuenta'),
                                  ),
                                );
                              }
                            }
                          },
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
