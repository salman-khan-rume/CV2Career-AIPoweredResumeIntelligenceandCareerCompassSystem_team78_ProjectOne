import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/analysis_result.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/score_circle.dart';
import '../widgets/loading_error_widgets.dart';

// Screen 7 (logged-in) + Screen 8 (guest).
// Detected at runtime via isGuestProvider.
// Guest sees a sign-in banner but can still upload and use compass.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(analysisHistoryProvider),
          child: CustomScrollView(
            slivers: [
              // Greeting header
              SliverToBoxAdapter(
                child: _HomeHeader(isGuest: isGuest, profile: profile),
              ),

              // Guest sign-in banner
              if (isGuest)
                SliverToBoxAdapter(
                  child: _GuestBanner(),
                ),

              // Quick action cards
              SliverToBoxAdapter(
                child: _QuickActions(),
              ),

              // Recent analyses header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingH,
                    AppDimens.sp24,
                    AppDimens.paddingH,
                    AppDimens.sp12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.recentAnalyses,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (!isGuest)
                        TextButton(
                          onPressed: () => context.go(AppRoutes.history),
                          child: const Text(AppStrings.viewAll),
                        ),
                    ],
                  ),
                ),
              ),

              // Recent analyses list
              if (isGuest)
                const SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    message: AppStrings.noAnalysesYet,
                    icon: Icons.description_outlined,
                  ),
                )
              else
                _RecentAnalysesList(),

              const SliverToBoxAdapter(child: SizedBox(height: AppDimens.sp32)),
            ],
          ),
        ),
      ),
    );
  }
}

// Greeting header with user name and time-based greeting.
class _HomeHeader extends ConsumerWidget {
  final bool isGuest;
  final AsyncValue profile;

  const _HomeHeader({required this.isGuest, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = AppUtils.timeGreeting();
    final name = isGuest
        ? 'Guest'
        : profile.when(
            data: (p) => p?.displayName ?? 'there',
            loading: () => '...',
            error: (_, __) => 'there',
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp24,
        AppDimens.paddingH,
        AppDimens.sp8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name!',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn().slideX(begin: -0.05, end: 0),
          const SizedBox(height: 4),
          Text(
            AppStrings.homeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ).animate().fadeIn(delay: 100.ms),
        ],
      ),
    );
  }
}

// Banner nudging guest users to sign in.
class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp12,
        AppDimens.paddingH,
        0,
      ),
      child: AppCard(
        color: AppColors.primarySurface,
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: AppDimens.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.guestBannerTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    AppStrings.guestBannerSub,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text(AppStrings.signInNow),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }
}

// Two quick-action cards: Upload Resume and Career Compass.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp20,
        AppDimens.paddingH,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              icon: Icons.upload_file_rounded,
              iconBg: AppColors.primarySurface,
              iconColor: AppColors.primary,
              title: AppStrings.uploadResumeCard,
              subtitle: AppStrings.uploadResumeCardSub,
              onTap: () => context.push(AppRoutes.upload),
              delay: 150,
            ),
          ),
          const SizedBox(width: AppDimens.sp12),
          Expanded(
            child: _ActionCard(
              icon: Icons.explore_rounded,
              iconBg: const Color(0xFFEDE9FE),
              iconColor: const Color(0xFF7C3AED),
              title: AppStrings.careerCompassCard,
              subtitle: AppStrings.careerCompassCardSub,
              onTap: () => context.go(AppRoutes.careerCompassQuestionnaire),
              delay: 250,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int delay;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm * 2),
            ),
            child: Icon(icon, color: iconColor, size: AppDimens.iconMd),
          ),
          const SizedBox(height: AppDimens.sp12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0);
  }
}

// Shows the 3 most recent analyses for logged-in users.
class _RecentAnalysesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(analysisHistoryProvider);

    return history.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.paddingH),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(analysisHistoryProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyStateWidget(
              message: AppStrings.noAnalysesYet,
              icon: Icons.description_outlined,
            ),
          );
        }
        final recent = items.take(3).toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingH,
                0,
                AppDimens.paddingH,
                AppDimens.sp12,
              ),
              child: _AnalysisHistoryCard(result: recent[index], index: index),
            ),
            childCount: recent.length,
          ),
        );
      },
    );
  }
}

// A single analysis result card in the recent list.
class _AnalysisHistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final int index;

  const _AnalysisHistoryCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.analysisResult, extra: result),
      child: Row(
        children: [
          ScoreCircle(
            score: result.overallScore,
            label: AppStrings.overallScore,
            size: AppDimens.scoreCircleSm,
            fontSize: 14,
          ),
          const SizedBox(width: AppDimens.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.resumeFileName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  AppUtils.formatDate(result.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'ATS: ${result.atsScore}/100',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.05, end: 0);
  }
}
