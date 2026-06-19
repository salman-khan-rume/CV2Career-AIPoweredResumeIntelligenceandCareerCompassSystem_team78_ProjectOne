import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/app_routes.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_error_widgets.dart';
import '../widgets/edit_profile_dialog.dart';

// Screen 17: Profile.
// Shows user info, edit option, total analyses, and sign-out button.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final themeMode = ref.watch(themeProvider);

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.profileTitle)),
        body: EmptyStateWidget(
          message: 'Sign in to view your profile and track your progress.',
          icon: Icons.person_outline,
          action: ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text(AppStrings.signInNow),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profileTitle),
        actions: [
          // Logout icon in AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppColors.danger,
            onPressed: () => _confirmSignOut(context, ref),
            tooltip: AppStrings.signOut,
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final profile = ref.watch(userProfileProvider);

          return profile.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, st) {
              return ErrorStateWidget(
                message: 'Failed to load profile.\nError: ${e.toString()}',
                onRetry: () => ref.invalidate(userProfileProvider),
              );
            },
            data: (user) {
              if (user == null) {
                return ErrorStateWidget(
                  message: 'No profile data available.',
                  onRetry: () => ref.invalidate(userProfileProvider),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppDimens.paddingH),
                children: [
                  // Avatar + name + edit button header
                  _ProfileHeader(
                    displayName: user.nameForGreeting,
                    email: user.email,
                  ).animate().fadeIn(),
                  const SizedBox(height: AppDimens.sp20),

                  // Stats: Total analyses + Member since
                  _StatsRow(
                    totalAnalyses: user.totalAnalyses,
                    memberSince: AppUtils.formatDate(user.createdAt),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppDimens.sp20),

                  // Menu section (History, Theme Toggle, About, Privacy)
                  _MenuSection(items: [
                    _MenuItem(
                      icon: Icons.history_outlined,
                      label: AppStrings.historyTitle,
                      onTap: () => context.go(AppRoutes.history),
                    ),
                    _MenuItem(
                      icon: themeMode == AppThemeMode.light
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      label: themeMode == AppThemeMode.light
                          ? 'Dark Mode'
                          : 'Light Mode',
                      onTap: () => ref.read(themeProvider.notifier).toggle(),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: AppStrings.aboutApp,
                      onTap: () => _showAbout(context),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: AppStrings.privacyPolicy,
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 150.ms),
                  const SizedBox(height: AppDimens.sp20),

                  // Sign out button (prominent at bottom)
                  _SignOutButton().animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppDimens.sp32),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.aboutApp),
        content: const Text(
          'CV2Career is an AI-powered resume analyser and career guidance app. '
          'Upload your resume to get ATS scores, improvement suggestions, '
          'and personalised career domain recommendations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text(AppStrings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ref.read(guestModeProvider.notifier).setGuest(false);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: Text(
              AppStrings.confirm,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

// Circular avatar + user name and email, with edit button.
class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;

  const _ProfileHeader({required this.displayName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primarySurface,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sp12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName.isEmpty ? 'User' : displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              color: AppColors.primary,
              onPressed: () => _showEditDialog(context, displayName),
              tooltip: AppStrings.editProfile,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Show edit profile dialog modal.
  void _showEditDialog(BuildContext context, String currentName) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(currentName: currentName),
    );
  }
}

// Total analyses + member since stats.
class _StatsRow extends StatelessWidget {
  final int totalAnalyses;
  final String memberSince;

  const _StatsRow({required this.totalAnalyses, required this.memberSince});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: AppStrings.totalAnalyses,
              value: totalAnalyses.toString(),
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _StatItem(
              label: AppStrings.memberSince,
              value: memberSince,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center),
      ],
    );
  }
}

// List of tappable menu items inside a card.
class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(e.value.icon, color: AppColors.primary, size: 22),
                title: Text(e.value.label,
                    style: Theme.of(context).textTheme.bodyMedium),
                trailing: Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
                onTap: e.value.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}

// Sign out button with confirmation dialog.
class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _confirmSignOut(context, ref),
      icon: const Icon(Icons.logout),
      label: const Text(
        AppStrings.signOut,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.danger,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.signOut),
        content: const Text(AppStrings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ref.read(guestModeProvider.notifier).setGuest(false);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.welcome);
            },
            child: Text(
              AppStrings.confirm,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
