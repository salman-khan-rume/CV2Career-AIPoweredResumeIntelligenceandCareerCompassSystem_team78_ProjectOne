import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_routes.dart';
import '../providers/auth_provider.dart';

// Screen 3: Welcome / Auth choice.
// Presents Login, Register, and Continue as Guest options per SRS 3.1.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo and title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: AppDimens.sp20),
              Text(
                AppStrings.welcomeTitle,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppDimens.sp8),
              Text(
                AppStrings.welcomeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const Spacer(flex: 2),

              // Auth buttons
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.login),
                child: const Text(AppStrings.loginButton),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppDimens.sp12),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text(AppStrings.registerButton),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppDimens.sp20),

              // Guest mode divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppDimens.sp12),
                    child: Text(
                      'or',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: AppDimens.sp20),
              TextButton(
                onPressed: () {
                  ref.read(guestModeProvider.notifier).setGuest(true);
                  context.go(AppRoutes.home);
                },
                child: const Text(AppStrings.continueAsGuest),
              ).animate().fadeIn(delay: 600.ms),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
