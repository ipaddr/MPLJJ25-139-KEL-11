import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SmartSchool';

  // Tema Warna Biru Dingin
  static const MaterialColor primaryBlue = MaterialColor(
    0xFF2196F3, // Biru standar
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  static const Color accentBlue = Color(0xFF03A9F4); // Biru muda cerah
  static const Color lightBlue = Color(0xFFBBDEFB); // Biru sangat muda
  static const Color darkBlue = Color(0xFF1976D2); // Biru gelap
}
