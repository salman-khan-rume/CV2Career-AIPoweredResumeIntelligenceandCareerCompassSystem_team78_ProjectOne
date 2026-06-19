import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_routes.dart';

class ConfirmEmailScreen extends StatelessWidget {
  const ConfirmEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated sent email icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shake(duration: 300.ms),

              const SizedBox(height: AppDimens.sp24),

              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppDimens.sp12),

              Text(
                'We have sent a verification link to your email address.\nPlease check your inbox and click the link to confirm your account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 350.ms),

              const Spacer(flex: 2),

              // Action buttons
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text(AppStrings.signInLink),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppDimens.sp12),

              OutlinedButton(
                onPressed: () => context.go(AppRoutes.register),
                child: const Text('Create Another Account'),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
