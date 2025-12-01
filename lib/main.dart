import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/home_page.dart';
import 'view/auth_screen.dart';
import 'view/styles.dart';
import 'viewmodel/todo_viewmodel.dart';
import 'services/auth_service.dart';

// ----------------------------------------------------------------------
// 1. Ejecución de la App (sin Supabase, usando backend Spring Boot)
// ----------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

// ----------------------------------------------------------------------
// 2. Definición de MyApp con MultiProvider
// ----------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos MultiProvider para gestionar el estado de varios ViewModels/Servicios
    return MultiProvider(
      providers: [
        // Proveedor para la Autenticación
        ChangeNotifierProvider(create: (_) => AuthService()), 
        
        // Proveedor existente para las Tareas (TodoViewModel)
        ChangeNotifierProvider(create: (_) => TodoViewModel()), 
      ],
      child: MaterialApp(
        title: 'To‑Do App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// 3. AuthWrapper - Decide qué pantalla mostrar
// ----------------------------------------------------------------------

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Si está autenticado, mostrar HomePage
        if (authService.isAuthenticated) {
          return const HomePage();
        }
        
        // Si no está autenticado, mostrar AuthScreen
        return const AuthScreen();
      },
    );
  }
}