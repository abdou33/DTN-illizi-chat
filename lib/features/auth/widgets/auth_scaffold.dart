import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final bool back;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.back = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: back
            ? IconButton(
                icon: const Icon(AppIcons.back, color: AppColors.darkGreen),
                onPressed: () => Navigator.pop(context),
              )
            : SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
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
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 36),
            child,
            if (footer != null) ...[const SizedBox(height: 20), footer!],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
