import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/patient/presentation/pages/patient_dashboard.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard.dart';
import '../utils/injection.dart';
import '../storage/storage_service.dart';
import 'splash_page.dart';

/// Configuración de rutas de la aplicación
/// Maneja la navegación y redirecciones basadas en el estado de autenticación
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String patientDashboard = '/patient-dashboard';
  static const String doctorDashboard = '/doctor-dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    redirect: _handleRedirect,
    routes: [
      // Pantalla de carga
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) {
          return const SplashPage();
        },
      ),

      // Rutas de autenticación
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),

      // Rutas del panel principal
      GoRoute(
        path: patientDashboard,
        name: 'patient-dashboard',
        builder: (context, state) {
          return const PatientDashboard();
        },
      ),
      GoRoute(
        path: doctorDashboard,
        name: 'doctor-dashboard',
        builder: (context, state) {
          final user = state.extra as User;
          return DoctorDashboard(doctor: user);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error de navegación: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(login),
                child: const Text('Ir al Login'),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// Maneja las redirecciones automáticas basadas en el estado de autenticación
  static Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
    try {
      final storageService = getIt<StorageService>();
      
      // Verificar si el usuario está autenticado
      final isAuthenticated = await storageService.isAuthenticated();
      final currentLocation = state.uri.toString();
      

      if (!isAuthenticated) {
        // Usuario no autenticado
        if (currentLocation == splash) {
          return null; // Permanecer en splash para verificar auth
        }
        if (currentLocation != login && currentLocation != register) {
          return login; // Redirigir al login
        }
      } else {
        // Usuario autenticado
        if (currentLocation == splash || currentLocation == login || currentLocation == register) {
          // Redirigir al dashboard apropiado según el tipo de usuario
          final userType = storageService.getUserType();
          
          if (userType == 'patient') {
            return patientDashboard;
          } else if (userType == 'doctor') {
            return doctorDashboard;
          }
        }
      }

      return null; // No se necesita redirección
    } catch (e) {
      return login;
    }
  }
}