import 'package:flutter/material.dart';

class AppLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // nombre del appbar
  final Color backgroundColor; // color del appbar
  final List<Widget>? actions;

  const AppLogoAppBar({
    super.key,
    required this.title,
    required this.backgroundColor,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // tamaño del appbar
  @override
  Widget build(BuildContext context) {
    final hasActions = actions != null && actions!.isNotEmpty;

    return AppBar(
      backgroundColor: backgroundColor,
      iconTheme: const IconThemeData(color: Colors.white),

      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo/logo_blanco.png',
            height: 35,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      actions: hasActions
          ? [...actions!]
          : [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
    );
  }
}
