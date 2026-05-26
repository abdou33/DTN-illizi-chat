import 'package:flutter/material.dart';

class AppColors {
  // WhatsApp iOS-style colors
  static const Color primaryGreen = Color(0xFF25D366);
  static const Color darkGreen = Color(0xFF128C7E);
  static const Color tealGreen = Color(0xFF075E54);
  static const Color lightGreen = Color(0xFFDCF8C6);
  
  // Chat bubble colors
  static const Color senderBubble = Color(0xFFDCF8C6);
  static const Color receiverBubble = Color(0xFFFFFFFF);
  
  // Background colors
  static const Color chatBackground = Color(0xFFECE5DD);
  static const Color scaffoldBackground = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFB0B0B0);
  
  // iOS-style colors
  static const Color iosBlue = Color(0xFF007AFF);
  static const Color iosSeparator = Color(0xFFC6C6C8);
  static const Color iosGroupedBackground = Color(0xFFF2F2F7);
  static const Color iosSecondaryBackground = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color online = Color(0xFF4CD964);
  static const Color error = Color(0xFFFF3B30);
  
  // Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF128C7E),
      Color(0xFF075E54),
    ],
  );
}
