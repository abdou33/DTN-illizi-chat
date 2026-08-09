import 'package:wilaya_illizi_chat/data/services/FCM_service.dart';
import 'package:wilaya_illizi_chat/data/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'app/dtn_chat_app.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FCMessagingService.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await MediaStore.ensureInitialized();
  MediaStore.appFolder = 'W33_chat';

  await AuthService.loadToken();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DtnChatApp());
}
