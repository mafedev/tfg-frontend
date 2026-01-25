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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo/logo_blanco.png', // ruta
            height: 35, // tamaño
            fit: BoxFit.contain, 
          ),
          const SizedBox(width: 8),
          // Título del appbar, evita que se desborde si el nombre es muy largo
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      // --------------- Foto de perfil a la derecha ---------------
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
