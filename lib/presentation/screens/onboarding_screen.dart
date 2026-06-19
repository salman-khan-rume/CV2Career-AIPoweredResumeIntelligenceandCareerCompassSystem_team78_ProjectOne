import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_routes.dart';

// Data for each of the 3 onboarding slides.
class _OnboardingSlide {
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
  });
}

final List<_OnboardingSlide> _slides = [
  _OnboardingSlide(
    title: AppStrings.onboarding1Title,
    body: AppStrings.onboarding1Body,
    icon: Icons.upload_file_rounded,
    iconColor: AppColors.primary,
  ),
  const _OnboardingSlide(
    title: AppStrings.onboarding2Title,
    body: AppStrings.onboarding2Body,
    icon: Icons.auto_awesome_rounded,
    iconColor: Color(0xFF8B5CF6),
  ),
  _OnboardingSlide(
    title: AppStrings.onboarding3Title,
    body: AppStrings.onboarding3Body,
    icon: Icons.explore_rounded,
    iconColor: AppColors.success,
  ),
];

// Screen 2: Onboarding walkthrough (3 slides).
// On completion, sets 'onboarding_done' in SharedPreferences and navigates to Welcome.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Marks onboarding as complete and navigates to the Welcome screen.
  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button row
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingH,
                  vertical: 8,
                ),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(AppStrings.onboardingSkip),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _SlidePage(slide: slide);
                },
              ),
            ),

            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppDimens.sp32),

            // Next / Get Started button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.paddingH),
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(isLast
                    ? AppStrings.onboardingGetStarted
                    : AppStrings.onboardingNext),
              ),
            ),
            const SizedBox(height: AppDimens.sp32),
          ],
        ),
      ),
    );
  }
}

// A single onboarding slide page.
class _SlidePage extends StatelessWidget {
  final _OnboardingSlide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon illustration area
          Container(
            width: AppDimens.onboardingImageHeight,
            height: AppDimens.onboardingImageHeight,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(slide.icon, size: 100, color: slide.iconColor),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppDimens.sp40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: AppDimens.sp16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ).animate().fadeIn(delay: 350.ms),
        ],
      ),
    );
  }
}
