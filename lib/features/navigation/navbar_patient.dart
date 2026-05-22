import 'package:flutter/material.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/appointment/presentation/screens/patient_appointment_screen.dart';
import 'package:tfg_frontend/features/prescription_tracking/presentation/screens/patient_prescription_tracking_screen.dart';
import 'package:tfg_frontend/features/home/presentation/screens/patient_home_screen.dart';
import 'package:tfg_frontend/features/profile/presentation/screens/patient_profile_screen.dart';
import 'package:tfg_frontend/features/routines/presentation/screens/patient_routine_screen.dart';

class NavbarPatient extends StatefulWidget {
  const NavbarPatient({super.key});

  @override
  State<NavbarPatient> createState() => _NavbarPatientState();
}

class _NavbarPatientState extends State<NavbarPatient> {
  int _currentPage = 0;

  final List<Widget> _pages = [
    const PatientHomeScreen(),
    const PatientRoutineScreen(),
    const PatientPrescriptionTrackingScreen(),
    const PatientAppointmentScreen(),
    const PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // asegura que los colores se apliquen correctamente
        selectedItemColor: AppColors.patientAccent, // color para cuando está seleccionado
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
          BottomNavigationBarItem(icon: Icon(Icons.fastfood_outlined), label: 'Rutina'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Medicina'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Citas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
