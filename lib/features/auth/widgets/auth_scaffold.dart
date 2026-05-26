import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosGroupedBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
