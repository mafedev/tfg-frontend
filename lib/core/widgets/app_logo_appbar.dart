import 'package:flutter/material.dart';

class AppLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // nombre del appbar
  final Color backgroundColor; // color del appbar

  const AppLogoAppBar({super.key, required this.title, required this.backgroundColor,});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // tamaño del appbar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      iconTheme: const IconThemeData(color: Colors.white), // todos los íconos blancos
      title: Row(
        children: [
          Image.asset(
            'assets/logo/logo_blanco.png', // ruta
            height: 40, // tamaño
            fit: BoxFit.contain, 
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
