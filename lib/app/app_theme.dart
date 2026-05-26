import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primaryGreen,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.iosGroupedBackground,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.iosSecondaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: AppColors.darkGreen),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
