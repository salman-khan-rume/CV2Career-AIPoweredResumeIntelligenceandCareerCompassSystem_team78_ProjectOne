import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/app_utils.dart';

// Animated circular score display used on Analysis Result and History screens.
// Colour changes based on score range (red/amber/green).
class ScoreCircle extends StatelessWidget {
  final int score;        // 0-100
  final String label;
  final double size;
  final double fontSize;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.label,
    this.size = AppDimens.scoreCircleLg,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppUtils.scoreColor(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: size / 2,
          lineWidth: 10,
          percent: score / 100,
          animation: true,
          animationDuration: 800,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: color,
          backgroundColor: AppColors.border,
          center: Text(
            '$score',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sp8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
