import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tfg_frontend/core/services/notification_service.dart';
import 'package:tfg_frontend/core/theme/app_colors.dart';
import 'package:tfg_frontend/features/auth/presentation/screens/login_screen.dart';

final notificationService = NotificationService(); // instancia del servicio de notificaciones

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté completamente inicializado antes de ejecutar el código
  await dotenv.load(fileName: '.env');
  notificationService.init(); // Inicializa el servicio de notificaciones

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: LoginScreen(),
      ),
    );
  }
}
