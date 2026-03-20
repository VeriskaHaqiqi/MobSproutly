import 'package:flutter/material.dart';

class AppColors {
  static const Color teal = Color(0xFF5DCFCF);
  static const Color tealLight = Color(0xFF7DE8D8);
  static const Color tealDark = Color(0xFF4ABFBF);
  static const Color greenLight = Color(0xFFA8E6CF);
  static const Color background = Color(0xFFF0F4F3);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color white = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealLight, teal],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7DE8D8),
      Color(0xFF5DCFCF),
      Color(0xFFA8E6CF),
    ],
  );
}
