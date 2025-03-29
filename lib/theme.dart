import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3CB043); // Xanh lá
  static const Color accentColor = Color(0xFFFFD700); // Vàng
  static const Color backgroundColor = Color(0xFFF5F5F5); // Màu nền
  static const Color textColor = Colors.black; // Màu chữ

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor, fontSize: 16),
        bodyMedium: TextStyle(color: textColor, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor),
        ),
      ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
    );
  }
}
