import 'package:flutter/material.dart';
import 'package:tfg_frontend/features/caregiver/caregiver_follow_up_screen.dart';
import 'package:tfg_frontend/features/caregiver/caregiver_home_screen.dart';
import 'package:tfg_frontend/features/caregiver/caregiver_patients_screen.dart';
import 'package:tfg_frontend/features/caregiver/caregivers_routines_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _currentPage = 0; // saber la página actual

  final List<Widget> _pages = [
    CaregiverHomeScreen(),
    CaregiverPatientsScreen(),
    CaregiversRoutinesScreen(),
    CaregiverFollowUpScreen(),
    Center(child: Text('Menú')),
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
          BottomNavigationBarItem(icon: Icon(Icons.people_alt),label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_calendar), label: 'Rutinas'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake_sharp), label: 'Seguimiento'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu')
        ],
      ),
    );
  }
}
