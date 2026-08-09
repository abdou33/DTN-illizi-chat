import 'package:wilaya_illizi_chat/features/chat/screens/appintro_screen.dart';
import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import 'app_theme.dart';

class DtnChatApp extends StatelessWidget {
  const DtnChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wilaya Illizi Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
