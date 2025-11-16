import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/app_colors.dart';
import 'package:tfg_frontend/features/patient/patient_emergency_screen.dart';
import 'package:tfg_frontend/features/patient/patient_follow_up_screen.dart';
import 'package:tfg_frontend/features/patient/patient_home_screen.dart';
import 'package:tfg_frontend/features/patient/patient_routine_screen.dart';

class NavbarPatient extends StatefulWidget {
  const NavbarPatient({super.key});

  @override
  State<NavbarPatient> createState() => _NavbarPatientState();
}

class _NavbarPatientState extends State<NavbarPatient> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    PatientHomeScreen(),
    PatientRoutineScreen(),
    PatientEmergencyScreen(),
    PatientFollowUpScreen(),
    Center(child: Text('Menú')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // asegura que los colores se apliquen correctamente
        selectedItemColor: AppColors.primary, // color para cuando está seleccionado
        unselectedItemColor: Colors.grey[600], // si no está seleccionado
        showUnselectedLabels: true,
        currentIndex: _currentPage,
        onTap: (index){
          setState(() {
            _currentPage = index;
          });
        },
        items: const[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month),label: 'Mi Rutina'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Emergencia'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake_sharp), label: 'Seguimiento'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu')
        ],
      ),

    );
  }
}
