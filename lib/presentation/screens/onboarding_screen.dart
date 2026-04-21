import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '👶',
      title: 'Find Trusted\nBabysitters',
      subtitle: 'Connect with verified, background-checked babysitters in your neighbourhood.',
      gradient: [Color(0xFF7C5CBF), Color(0xFFA88FD4)],
    ),
    _OnboardingPage(
      emoji: '🛡️',
      title: 'Your Trust Circle',
      subtitle: 'Build a network of trusted carers. They get first priority for emergency bookings.',
      gradient: [Color(0xFF5A3D9A), Color(0xFF7C5CBF)],
    ),
    _OnboardingPage(
      emoji: '⚡',
      title: 'Book in Minutes',
      subtitle: 'Scheduled or emergency — get a reliable sitter whenever you need one.',
      gradient: [Color(0xFFE8A0B4), Color(0xFF7C5CBF)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _pages[i],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
          Positioned(
            top: 60,
            right: AppSizes.pageHorizontal,
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pageHorizontal,
        AppSizes.lg,
        AppSizes.pageHorizontal,
        AppSizes.lg + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          if (isLast) ...[
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSizes.sm),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Already have an account? Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ] else
            ElevatedButton(
              onPressed: () => _controller.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pageHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(emoji, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: AppSizes.xl),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

