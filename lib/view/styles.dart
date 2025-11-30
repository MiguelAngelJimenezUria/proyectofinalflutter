import 'package:flutter/material.dart';

// Colores basados en el diseño de referencia: Azul Profundo (Primario) y Naranja/Salmón (Acento)
class AppColors {
  static const primary = Color(0xFF4A47A3); // Azul/Púrpura oscuro para fondo y cabeceras
  static const accent = Color(0xFFF7745E); // Naranja/Salmón vibrante para acentos y FAB
  static const textPrimary = Color(0xFF263238); // Gris oscuro para el cuerpo de texto
  static const background = Color(0xFFF0F4F8); // Fondo muy claro y limpio
  static const cardColor = Colors.white; // Color de las tarjetas
  static const shadowColor = Color(0xFF4A47A3); // Sombra sutil del primario
  static const Color textSecondary = Color(0xFF666666);
}

class AppTextStyles {
  // Estilos de texto adaptados al tema
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28, 
    fontWeight: FontWeight.bold, 
    color: AppColors.textPrimary
  );
  static final TextStyle subtitle = TextStyle(
    fontSize: 14, 
    color: Colors.grey[700]
  );
  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 28,
  );
  static TextStyle headerSubtitle = TextStyle(
    color: Colors.white.withOpacity(0.8),
    fontSize: 16,
  );
}