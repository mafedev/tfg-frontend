import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/caregiver/follow_up/screens/caregiver_follow_up_screen.dart';
import 'package:tfg_frontend/features/caregiver/home/screens/caregiver_home_screen.dart';
import 'package:tfg_frontend/features/caregiver/patients_list/screens/caregiver_patients_screen.dart';
import 'package:tfg_frontend/features/caregiver/medication/screens/caregivers_create_medication_screen.dart';

class NavbarCaregiver extends StatefulWidget {
  const NavbarCaregiver({super.key});

  @override
  State<NavbarCaregiver> createState() => _NavbarCaregiverState();
}

class _NavbarCaregiverState extends State<NavbarCaregiver> {
  int _currentPage = 0; // saber la página actual

  final List<Widget> _pages = [
    CaregiverHomeScreen(),
    CaregiverPatientsScreen(),
    CaregiversMedicationScreen(),
    CaregiverFollowUpScreen(),
    Center(child: Text('Menú')),
  ];
  // páginas / screens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // asegura que los colores se apliquen correctamente
        selectedItemColor: AppColors.caregiverAccent, // color para cuando está seleccionado
        unselectedItemColor: Colors.grey[600], // si no está seleccionado
        showUnselectedLabels: true,
        currentIndex: _currentPage,
        onTap: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt),label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Medicación'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake_sharp), label: 'Seguimiento'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu')
        ],
      ),
    );
  }
}
