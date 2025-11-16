import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/caregiver_home_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentPage = 0; // saber la página actual

  final List<Widget> _pages = [
    CaregiverHomeScreen(),
    Center(child: Text('Segunda pestaña')),
  ];
  // páginas / screens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: const [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Opciones'),
],

      ),
    );
  }
}
