import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/career_domain.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/skill_tag.dart';

// Screen 13: Career Compass Results.
// Shows the ranked list of career domain recommendations from AI.
// Tapping a card navigates to the Domain Detail screen.
class CareerCompassResultsScreen extends StatelessWidget {
  final List<CareerDomain> domains;
  const CareerCompassResultsScreen({super.key, required this.domains});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.careerCompassResultTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimens.paddingH),
        itemCount: domains.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimens.sp12),
        itemBuilder: (context, index) {
          return _DomainResultCard(
            domain: domains[index],
            rank: index + 1,
            animDelay: index * 100,
          );
        },
      ),
    );
  }
}

// A ranked career domain result card.
class _DomainResultCard extends StatelessWidget {
  final CareerDomain domain;
  final int rank;
  final int animDelay;

  const _DomainResultCard({
    required this.domain,
    required this.rank,
    required this.animDelay,
  });

  @override
  Widget build(BuildContext context) {
    // Top match gets a highlighted border.
    final isTopMatch = rank == 1;

    return AppCard(
      borderRadius: AppDimens.radiusCard,
      color: isTopMatch ? AppColors.primarySurface : AppColors.card,
      onTap: () => context.push(AppRoutes.careerDomainDetail, extra: domain),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isTopMatch ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color:
                          isTopMatch ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sp12),
              Expanded(
                child: Text(
                  domain.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              // Match percent badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.sp12, vertical: AppDimens.sp4),
                decoration: BoxDecoration(
                  color: AppUtils.scoreSurface(domain.matchPercent),
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Text(
                  '${domain.matchPercent}% ${AppStrings.matchPercent}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppUtils.scoreColor(domain.matchPercent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sp12),

          // AI reasoning snippet
          Text(
            domain.aiReasoning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.sp12),

          // Top required skills
          SkillTagRow(skills: domain.requiredSkills.take(3).toList()),
          const SizedBox(height: AppDimens.sp12),

          // Skill Gap CTA
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.skillGap, extra: {
                      'domainKey': domain.key,
                      'userSkills': <String>[],
                    });
                  },
                  icon: const Icon(Icons.analytics_outlined, size: 16),
                  label: const Text(AppStrings.viewSkillGapButton),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, AppDimens.buttonHeightSm),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sp8),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay))
        .slideY(begin: 0.06, end: 0);
  }
}
