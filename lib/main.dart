import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/dtn_chat_app.dart';
import 'core/constants/app_colors.dart';
import 'data/services/local_db.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDb().init();

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
