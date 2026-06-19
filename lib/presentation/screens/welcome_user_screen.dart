import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../providers/auth_provider.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';

class WelcomeUserScreen extends ConsumerWidget {
  const WelcomeUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    final name = profile.when(
      data: (user) => user?.nameForGreeting ?? 'there',
      loading: () => '...',
      error: (_, __) => 'there',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.sp32),

              // Personalized Header
              Center(
                child: Text(
                  'Welcome, $name!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),

              const SizedBox(height: AppDimens.sp8),

              Text(
                "Here is how CV2Career will guide your path:",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppDimens.sp32),

              // Feature 1: Resume Analysis
              _FeatureCard(
                icon: Icons.analytics_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primarySurface,
                title: 'AI Resume Intelligence',
                description: 'Upload your resume to get instant ATS scores, format analyses, and missing keyword suggestions.',
                delay: 350,
              ),

              const SizedBox(height: AppDimens.sp16),

              // Feature 2: Career Compass
              const _FeatureCard(
                icon: Icons.explore_outlined,
                iconColor: Color(0xFF7C3AED),
                iconBgColor: Color(0xFFEDE9FE),
                title: 'Career Compass',
                description: 'Take a short, interactive questionnaire to match your profile and interests with ideal career domains.',
                delay: 500,
              ),

              const SizedBox(height: AppDimens.sp16),

              // Feature 3: Skill Gap Analyser
              _FeatureCard(
                icon: Icons.trending_up_outlined,
                iconColor: AppColors.success,
                iconBgColor: AppColors.successSurface,
                title: 'Skill Gap Analyser',
                description: 'Generate a personalized, step-by-step roadmap to bridge skills and certification gaps for your target job.',
                delay: 650,
              ),

              const Spacer(),

              // Get Started button
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Get Started'),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppDimens.sp24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String description;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.description,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sp12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimens.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.05, end: 0);
  }
}
