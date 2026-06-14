import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_theme.dart';

// Standard card container matching the CV2Career design system:
// white background, 1px #E5E5E5 border, 0px 2px 8px rgba(0,0,0,0.06) shadow, 12px radius.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.circular(borderRadius ?? AppDimens.radiusCard),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        padding: padding ?? const EdgeInsets.all(AppDimens.paddingH),
        child: child,
      ),
    );
  }
}
