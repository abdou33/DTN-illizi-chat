import 'package:dio/dio.dart';
import 'package:dtn_chat/core/constants/app_urls.dart';
import 'package:dtn_chat/core/utils/ui_utils.dart';
import 'package:dtn_chat/data/models/chat_model.dart';
import 'package:dtn_chat/features/auth/screens/log_in_screen.dart';
import 'package:dtn_chat/features/auth/screens/register_screen.dart';
import 'package:dtn_chat/features/chat/screens/appintro_screen.dart';
import 'package:dtn_chat/features/chat/screens/disactivated_account.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/local_db.dart';
import '../auth/screens/welcome_screen.dart';
import '../chat/screens/chats_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _fadeOut;
  var logger = Logger();
  final dio = Dio();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScale = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)),
    );
    _fadeOut = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _logoCtrl.forward();
    _isfirsttime();
  }

  Future<void> _isfirsttime() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isfirst = prefs.getBool("first");
    print("first ::: ${isfirst}");
    if (isfirst == true) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => AppIntroScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      _goNext();
    }
    ;
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _fadeCtrl.forward();
    if (!mounted) return;
    bool loggedIn = await AuthService().userisloggedin();
    bool isdisabled = false;
    if (loggedIn) {
      isdisabled = await verifyserver();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => loggedIn
            ? isdisabled
                  ? DisactivatedAccountScreen()
                  : const ChatsScreen()
            : const LogInScreen(), // WelcomeScreen previously
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  Future<bool> verifyserver() async {
    try {
      final response = await dio.get(
        "${AppUrls.api_url}/api/check-account",
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          validateStatus: (status) => true, // accept all codes
        ),
      );
      // logger.i("response: ${response.data}");
      // logger.i("status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data["is_disabled"];
      } else {
        throw Exception(
          response.data['error']?.toString() ??
              'Request failed with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      // logger.e(e);
      if (mounted) {
        showAppSnackBar(context, cleanErrorMessage(e), isError: true);
      }
    }
    return false;
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeCtrl, _logoCtrl]),
        builder: (_, __) => Opacity(
          opacity: _fadeOut.value,
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.splashGradient),
            child: Center(
              child: Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // child: const Icon(AppIcons.chatBold, size: 60, color: AppColors.tealGreen),
                    child: Image.asset(
                      height: 60,
                      width: 60,
                      "assets/logo_green_transparent.png",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
