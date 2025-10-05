import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 200, height: 200, child: Placeholder()),
          Text("Nombre de la APP"),
        ],
      ),
    );
  }
}
