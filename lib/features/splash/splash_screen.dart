import 'package:dtn_whatsapp_clone/features/auth/screens/log_in_screen.dart';
import 'package:dtn_whatsapp_clone/features/auth/screens/register_screen.dart';
import 'package:flutter/material.dart';
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
    _goNext();
  }

  Future<void> _goNext() async {
    await LocalDb().init();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _fadeCtrl.forward();
    if (!mounted) return;
    final loggedIn = AuthService().currentUser != null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) =>
            loggedIn ? const ChatsScreen() : const WelcomeScreen(), // WelcomeScreen previously
            // loggedIn ? const ChatsScreen() : const LogInScreen(), // WelcomeScreen previously
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
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
