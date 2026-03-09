import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primary,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

  );
}
