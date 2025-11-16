import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/auth/auth_service.dart';
import 'package:tfg_frontend/features/auth/signup_screen.dart';
import 'package:tfg_frontend/features/caregiver/caregiver_home_screen.dart';
import 'package:tfg_frontend/features/navigation/navbar.dart';
import 'package:tfg_frontend/features/patient/patient_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // clave para acceder al estado del Form (validación, save, reset)
  final emailController = TextEditingController(); // controlador para el campo de correo (leer/limpiar/escuchar texto)
  final passwordController = TextEditingController(); // controlador para el campo de contraseña

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 420; // límite de ancho para centrar en pantallas grandes

    return Scaffold(
      // Quitamos el backgroundColor para que se vea el fondo pintado
      body: CustomPaint(
        // painter: DiagonalBackgroundPainter(), // Pinta el fondo con la diagonal
        child: SafeArea(
          // Evita que el contenido quede detrás de cosas del sistema
          child: Center(
            // Centra el contenido
            child: ConstrainedBox(
              // Limita el ancho máximo del contenido a maxWidth
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                // Espacio alrededor de la tarjeta
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Card(
                  // Tarjeta para el formulario
                  elevation: 4, // Sombra
                  shape: RoundedRectangleBorder(
                    // Bordes redondeados
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    // Padding interno de la tarjeta
                    padding: const EdgeInsets.all(20),

                    // ----------- Formulario -----------
                    child: Form(
                      key: _formKey, // Clave del formulario
                      child: Column(
                        // Columna para los campos y botones
                        mainAxisSize: MainAxisSize.min, // ocupa solo lo necesario
                        crossAxisAlignment: CrossAxisAlignment.stretch, // estira hijos horizontalmente
                        children: [
                          const Text(
                            'Bienvenido', // título del formulario
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12), // separación vertical

                          // ----------- Correo -----------
                          TextFormField(
                            controller: emailController, // conecta el TextFormField con emailController
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              hintText: 'tucorreo@ejemplo.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType
                                .emailAddress, // Que el teclado sea de email
                          ),
                          const SizedBox(height: 12), // separación

                          // ----------- Contraseña -----------
                          TextFormField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            // obscureText: true,
                            validator: (v) => (v == null || v.isEmpty)  // validación simple, si está vacío devuelve el mensaje, si no, nulo (válido)
                                ? 'Introduce tu contraseña'
                                : null,
                          ),
                          const SizedBox(height: 16), // separación

                          // ----------- Botón de login -----------
                          ElevatedButton(
                            onPressed: () async { // cuando se pulsa, valida el formulario
                            // si el estado del formulario no es null, y todos los campos son válidos
                            // el ?? es como un else, pone false en caso de que currentState sea null
                              if (_formKey.currentState?.validate() ?? false) { 
                                final authService = AuthService(); // instancia
                                // llama al método de login del AuthService
                                final userData = await authService.login(
                                  emailController.text,
                                  passwordController.text,
                                );

                                // si el login fue exitoso
                                if (userData != null) {
                                  // muestra un snackbar de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Inicio de sesión correcto',
                                      ),
                                    ),
                                  );
                                  // navega a la pantalla del rol especifico
                                  // "pushReplacement" reemplaza la pantalla actual (ya no se puede volver atrás)
                                  String role = userData['role'];

                                  if(role == 'Cuidador'){ // si es cuidador, muestra el home de cuidador
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => Navbar())
                                    );
                                  } else if(role == 'Paciente'){ // si es paciente muestra el home de paciente
                                    Navigator.pushReplacement(
                                      context, 
                                      MaterialPageRoute(builder: (_) => const PatientHomeScreen())
                                      );
                                  }
                                } else {
                                  // si el login falló, muestra un snackbar de error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Credenciales incorrectas'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom( // estilo del botón
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Iniciar sesión'), // texto del botón
                          ),

                          // ----------- Enlace a Signup -----------
                          const SizedBox(height: 8), // separación
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
                                child: const Text('Regístrate'), // texto del botón
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

// class DiagonalBackgroundPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();

//     // Color superior izquierdo
//     paint.color = AppColors.primary;
//     final path1 = Path()
//       ..moveTo(0, 0)
//       ..lineTo(size.width, 0)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path1, paint);

//     // Color inferior derecho
//     paint.color = AppColors.secondary;
//     final path2 = Path()
//       ..moveTo(size.width, 0)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//     canvas.drawPath(path2, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
