import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

// Small pill-shaped tag for displaying individual skills or keywords.
// Used on Career Compass results, Skill Gap, and Domain Detail screens.
class SkillTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const SkillTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sp12,
        vertical: AppDimens.sp4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

// Wraps a list of skill strings into a Wrap of SkillTag widgets.
class SkillTagRow extends StatelessWidget {
  final List<String> skills;
  final Color? backgroundColor;
  final Color? textColor;

  const SkillTagRow({
    super.key,
    required this.skills,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sp8,
      runSpacing: AppDimens.sp8,
      children: skills
          .map((s) => SkillTag(
                label: s,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ))
          .toList(),
    );
  }
}
