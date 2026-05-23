import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.quoteAccent,
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      );
}
