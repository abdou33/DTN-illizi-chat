import 'package:wilaya_illizi_chat/features/auth/screens/log_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:wilaya_illizi_chat/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppIntroScreen extends StatefulWidget {
  const AppIntroScreen({super.key});

  @override
  State<AppIntroScreen> createState() => _AppIntroScreenState();
}

class _AppIntroScreenState extends State<AppIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_IntroPage> _pages = const [
    _IntroPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Welcome to Wilaya Illizi Chat',
      description:
          'A private communication platform provided by Wilaya Illizi for authorized personnel and users.',
    ),
    _IntroPage(
      icon: Icons.dns_rounded,
      title: 'Your Data, DTN Servers',
      description:
          'Your account information, conversations, and shared files are securily stored on servers managed by DTN Illizi.',
    ),
    _IntroPage(
      icon: Icons.verified_user_rounded,
      title: 'Private & Secure',
      description:
          'Wilaya Illizi Chat is intended for authorized users. Please keep your account credentials private and use the application responsibly.',
    ),
  ];

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();

    bool notfirstanymore = await prefs.setBool("first", false);
    // Save a preference here so this screen isn't shown again.
    if (notfirstanymore) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LogInScreen()));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (_, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: AppColors.darkGreen,
                          ),
                        ),

                        const SizedBox(height: 45),

                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final selected = index == _currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.darkGreen
                        : AppColors.darkGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage {
  final IconData icon;
  final String title;
  final String description;

  const _IntroPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
