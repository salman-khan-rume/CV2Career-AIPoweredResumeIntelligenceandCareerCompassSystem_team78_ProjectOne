import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/career_domain.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/skill_tag.dart';
import '../widgets/score_circle.dart';

// Screen 14: Career Domain Detail.
// Displays the full domain profile: match %, acceptance probability,
// AI reasoning, required skills, and certifications.
class CareerDomainDetailScreen extends StatelessWidget {
  final CareerDomain domain;
  const CareerDomainDetailScreen({super.key, required this.domain});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.domainDetailTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card with scores
            _DomainHeaderCard(domain: domain).animate().fadeIn(),
            const SizedBox(height: AppDimens.sp16),

            // AI reasoning
            _SectionCard(
              title: AppStrings.whyThisDomain,
              icon: Icons.auto_awesome_outlined,
              child: Text(
                domain.aiReasoning,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppDimens.sp16),

            // Required skills
            _SectionCard(
              title: AppStrings.requiredSkills,
              icon: Icons.checklist_rounded,
              child: SkillTagRow(skills: domain.requiredSkills),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppDimens.sp16),

            // Certifications
            if (domain.certifications.isNotEmpty) ...[
              _SectionCard(
                title: AppStrings.certifications,
                icon: Icons.workspace_premium_outlined,
                child: Column(
                  children: domain.certifications
                      .map((cert) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppDimens.sp8),
                            child: Row(
                              children: [
                                Icon(Icons.star_outline,
                                    size: 16, color: AppColors.warning),
                                const SizedBox(width: AppDimens.sp8),
                                Expanded(
                                  child: Text(
                                    cert,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppDimens.sp24),
            ],

            // Skill Gap CTA
            ElevatedButton.icon(
              onPressed: () {
                context.push(AppRoutes.skillGap, extra: {
                  'domainKey': domain.key,
                  'userSkills': <String>[],
                });
              },
              icon: const Icon(Icons.analytics_outlined),
              label: const Text(AppStrings.viewSkillGapButton),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: AppDimens.sp32),
          ],
        ),
      ),
    );
  }
}

// Header card showing domain name + match % circle + acceptance probability bar.
class _DomainHeaderCard extends StatelessWidget {
  final CareerDomain domain;
  const _DomainHeaderCard({required this.domain});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(domain.label,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.sp20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ScoreCircle(
                score: domain.matchPercent,
                label: '${AppStrings.matchPercent} match',
                size: AppDimens.scoreCircleMd,
                fontSize: 20,
              ),
              Container(width: 1, height: 70, color: AppColors.border),
              // Acceptance probability column
              Column(
                children: [
                  Text(
                    '${domain.acceptanceProbability}%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color:
                              AppUtils.scoreColor(domain.acceptanceProbability),
                        ),
                  ),
                  const SizedBox(height: AppDimens.sp4),
                  Text(
                    AppStrings.acceptanceProbability,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sp20),

          // Acceptance probability linear bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.acceptanceProbability,
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppDimens.sp8),
              LinearPercentIndicator(
                percent: domain.acceptanceProbability / 100,
                lineHeight: 10,
                animation: true,
                animationDuration: 800,
                backgroundColor: AppColors.border,
                progressColor:
                    AppUtils.scoreColor(domain.acceptanceProbability),
                barRadius: const Radius.circular(5),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Generic labelled section card.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppDimens.sp8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimens.sp16),
          child,
        ],
      ),
    );
  }
}
