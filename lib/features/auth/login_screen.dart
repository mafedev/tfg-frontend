import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold provides the Material ancestor required by TextField
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Correo
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Introduce tu correo",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
            ),
            // Contraseña
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Introduce tu contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.remove_red_eye),
                ),
                obscureText: true,
              ),
            ),

            // Botón de login
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: ElevatedButton(onPressed: () {}, child: const Text("Login")),
            ),
          ],
        ),
      ),
    );
  }
}
