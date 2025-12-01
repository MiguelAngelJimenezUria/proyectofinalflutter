import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 Importar Supabase
import 'view/home_page.dart';
import 'view/styles.dart';
import 'viewmodel/todo_viewmodel.dart';

// Importar el servicio de autenticación
import 'services/auth_service.dart'; // Asegúrate de que esta ruta sea correcta

// ----------------------------------------------------------------------
// 1. Inicialización de Supabase y Ejecución de la App
// ----------------------------------------------------------------------

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized(); 

  // Inicialización de Supabase (¡MUY IMPORTANTE!)
  // Las constantes supabaseUrl y supabaseAnonKey se obtienen de auth_service.dart
  await Supabase.initialize(
    url: supabaseUrl, 
    anonKey: supabaseAnonKey,
    debug: true,
  );

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
        // Proveedor para la Autenticación de Supabase (AuthService)
        ChangeNotifierProvider(create: (_) => AuthService()), 
        
        // Proveedor existente para las Tareas (TodoViewModel)
        ChangeNotifierProvider(create: (_) => TodoViewModel()), 
      ],
      child: MaterialApp(
        title: 'To‑Do App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const HomePage(),
      ),
    );
  }
}