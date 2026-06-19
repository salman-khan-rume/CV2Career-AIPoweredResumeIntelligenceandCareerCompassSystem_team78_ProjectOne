import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/skill_gap.dart';
import '../../data/services/skill_gap_service.dart';
import '../widgets/app_card.dart';
import '../widgets/skill_tag.dart';

// Screen 15: Skill Gap Analyser.
// Computes and displays skill gaps for a selected career domain
// using local benchmark data + user's resume skills.
class SkillGapScreen extends ConsumerStatefulWidget {
  final String domainKey;
  final List<String> userSkills;

  const SkillGapScreen({
    super.key,
    required this.domainKey,
    required this.userSkills,
  });

  @override
  ConsumerState<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends ConsumerState<SkillGapScreen> {
  late final SkillGapReport _report;

  @override
  void initState() {
    super.initState();
    // Skill gap computation is synchronous (local benchmark data).
    _report = SkillGapService().generateReport(
      domainKey: widget.domainKey,
      userSkills: widget.userSkills,
    );
  }

  @override
  Widget build(BuildContext context) {
    final certs = _report.roadmap
        .where((s) => s.certSuggestion != null)
        .map((s) => s.certSuggestion!)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.skillGapTitle),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompletenessCard(report: _report).animate().fadeIn(),
            const SizedBox(height: AppDimens.sp20),
            _StatusLegend().animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppDimens.sp20),
            _SkillListSection(report: _report).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: AppDimens.sp20),
            if (_report.roadmap.isNotEmpty) ...[
              _RoadmapSection(roadmap: _report.roadmap)
                  .animate()
                  .fadeIn(delay: 200.ms),
              const SizedBox(height: AppDimens.sp20),
            ],
            if (certs.isNotEmpty)
              _CertSection(certs: certs).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: AppDimens.sp32),
          ],
        ),
      ),
    );
  }
}

// Top card showing domain name and overall completeness score.
class _CompletenessCard extends StatelessWidget {
  final SkillGapReport report;
  const _CompletenessCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(report.domainLabel,
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppDimens.sp16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill Completeness',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppDimens.sp8),
                    LinearPercentIndicator(
                      percent: report.completenessPercent / 100,
                      lineHeight: 12,
                      animation: true,
                      animationDuration: 900,
                      backgroundColor: AppColors.border,
                      progressColor: _completenessColor(report.completenessPercent),
                      barRadius: const Radius.circular(6),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sp16),
              Text(
                '${report.completenessPercent}%',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: _completenessColor(report.completenessPercent),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sp12),
          Row(
            children: [
              _StatChip('${report.presentSkills.length} Present', AppColors.success),
              const SizedBox(width: AppDimens.sp8),
              _StatChip('${report.partialSkills.length} Partial', AppColors.warning),
              const SizedBox(width: AppDimens.sp8),
              _StatChip('${report.missingSkills.length} Missing', AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Color _completenessColor(int pct) {
    if (pct >= 70) return AppColors.success;
    if (pct >= 40) return AppColors.warning;
    return AppColors.danger;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// Colour-coded legend for skill statuses.
class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(AppColors.success, AppStrings.skillPresent),
        const SizedBox(width: AppDimens.sp16),
        _LegendItem(AppColors.warning, AppStrings.skillPartial),
        const SizedBox(width: AppDimens.sp16),
        _LegendItem(AppColors.danger, AppStrings.skillMissing),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// Full list of all benchmark skills with status indicators.
class _SkillListSection extends StatelessWidget {
  final SkillGapReport report;
  const _SkillListSection({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Skills', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimens.sp16),
          ...report.skills.map((item) => _SkillRow(item: item)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  final SkillGapItem item;
  const _SkillRow({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case SkillStatus.present:
        return AppColors.success;
      case SkillStatus.partial:
        return AppColors.warning;
      case SkillStatus.missing:
        return AppColors.danger;
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case SkillStatus.present:
        return Icons.check_circle_outline;
      case SkillStatus.partial:
        return Icons.radio_button_checked;
      case SkillStatus.missing:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sp12),
      child: Row(
        children: [
          Icon(_statusIcon, size: 20, color: _statusColor),
          const SizedBox(width: AppDimens.sp12),
          Expanded(
            child: Text(
              item.skill,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Weight indicator dots
          Row(
            children: List.generate(
              (item.weight / 2).ceil().clamp(1, 5),
              (i) => Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < (item.weight / 2).ceil()
                        ? AppColors.primary
                        : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Prioritised improvement roadmap (missing + partial, sorted by weight).
class _RoadmapSection extends StatelessWidget {
  final List<SkillGapItem> roadmap;
  const _RoadmapSection({required this.roadmap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: AppDimens.sp8),
              Text(AppStrings.improvementRoadmap,
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimens.sp4),
          Text(
            'Sorted by impact on your acceptance probability',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimens.sp16),
          ...roadmap.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sp12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sp12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value.skill,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (e.value.status == SkillStatus.partial)
                            Text(
                              'Partially present - strengthen this',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.warning),
                            )
                          else
                            Text(
                              'Not found in your resume - learn this',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.danger),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// Certification recommendations for missing/partial skills.
class _CertSection extends StatelessWidget {
  final List<String> certs;
  const _CertSection({required this.certs});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: AppDimens.sp8),
              Text(AppStrings.recommendedCerts,
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimens.sp12),
          SkillTagRow(
            skills: certs,
            backgroundColor: AppColors.warningSurface,
            textColor: AppColors.warning,
          ),
        ],
      ),
    );
  }
}
