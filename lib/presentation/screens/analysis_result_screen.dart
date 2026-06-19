import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/analysis_result.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/score_circle.dart';
import '../widgets/skill_tag.dart';

// Screen 10: Analysis Result.
// Displays overall score, ATS score, suggestions (Add/Remove/Improve),
// missing sections, weak language, and missing keywords.
// CTA buttons lead to Career Compass and Skill Gap.
class AnalysisResultScreen extends ConsumerWidget {
  final AnalysisResult result;
  const AnalysisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analysisResultTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score row
            _ScoreRow(result: result).animate().fadeIn(),
            const SizedBox(height: AppDimens.sp24),

            // Suggestions section
            _SuggestionsSection(result: result).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: AppDimens.sp20),

            // Missing sections
            if (result.missingSections.isNotEmpty) ...[
              _TagSection(
                title: AppStrings.missingSections,
                icon: Icons.playlist_remove_rounded,
                iconColor: AppColors.danger,
                tags: result.missingSections,
                tagBg: AppColors.dangerSurface,
                tagText: AppColors.danger,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppDimens.sp16),
            ],

            // Weak language
            if (result.weakLanguage.isNotEmpty) ...[
              _TagSection(
                title: AppStrings.weakLanguage,
                icon: Icons.edit_off_outlined,
                iconColor: AppColors.warning,
                tags: result.weakLanguage,
                tagBg: AppColors.warningSurface,
                tagText: AppColors.warning,
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: AppDimens.sp16),
            ],

            // Missing keywords
            if (result.missingKeywords.isNotEmpty) ...[
              _TagSection(
                title: AppStrings.missingKeywords,
                icon: Icons.vpn_key_outlined,
                iconColor: AppColors.primary,
                tags: result.missingKeywords,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppDimens.sp24),
            ],

            // CTA: Career Compass
            ElevatedButton.icon(
              onPressed: () {
                // Store the resume file name as context for compass;
                // full text would come from the in-memory resumeTextProvider.
                context.go(AppRoutes.careerCompassQuestionnaire);
              },
              icon: const Icon(Icons.explore_rounded),
              label: const Text(AppStrings.viewCareerCompass),
            ).animate().fadeIn(delay: 350.ms),

            const SizedBox(height: AppDimens.sp32),
          ],
        ),
      ),
    );
  }
}

// Displays Overall Score and ATS Score side by side.
class _ScoreRow extends StatelessWidget {
  final AnalysisResult result;
  const _ScoreRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScoreCircle(
            score: result.overallScore,
            label: AppStrings.overallScore,
            size: AppDimens.scoreCircleLg,
            fontSize: 32,
          ),
          Container(width: 1, height: 100, color: AppColors.border),
          ScoreCircle(
            score: result.atsScore,
            label: AppStrings.atsScore,
            size: AppDimens.scoreCircleLg,
            fontSize: 32,
          ),
        ],
      ),
    );
  }
}

// Three suggestion category sections (Add, Remove, Improve).
class _SuggestionsSection extends StatelessWidget {
  final AnalysisResult result;
  const _SuggestionsSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.suggestions,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppDimens.sp16),
          if (result.addSuggestions.isNotEmpty)
            _SuggestionGroup(
              label: AppStrings.addSuggestions,
              color: AppColors.success,
              bg: AppColors.successSurface,
              icon: Icons.add_circle_outline,
              items: result.addSuggestions.map((s) => s.text).toList(),
            ),
          if (result.removeSuggestions.isNotEmpty)
            _SuggestionGroup(
              label: AppStrings.removeSuggestions,
              color: AppColors.danger,
              bg: AppColors.dangerSurface,
              icon: Icons.remove_circle_outline,
              items: result.removeSuggestions.map((s) => s.text).toList(),
            ),
          if (result.improveSuggestions.isNotEmpty)
            _SuggestionGroup(
              label: AppStrings.improveSuggestions,
              color: AppColors.warning,
              bg: AppColors.warningSurface,
              icon: Icons.edit_note_rounded,
              items: result.improveSuggestions.map((s) => s.text).toList(),
            ),
        ],
      ),
    );
  }
}

class _SuggestionGroup extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  final List<String> items;

  const _SuggestionGroup({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppDimens.sp6),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sp8),
          ...items.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sp8),
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.sp12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm * 2),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// Generic tag/chip section for missing items, weak language, keywords.
class _TagSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<String> tags;
  final Color? tagBg;
  final Color? tagText;

  const _TagSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.tags,
    this.tagBg,
    this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppDimens.sp8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppDimens.sp12),
          SkillTagRow(
            skills: tags,
            backgroundColor: tagBg,
            textColor: tagText,
          ),
        ],
      ),
    );
  }
}
