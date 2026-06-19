import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_routes.dart';
import '../providers/career_compass_provider.dart';
import '../widgets/loading_error_widgets.dart';

// Screen 12: Career Compass Analysing.
// Shown while the AI is generating career recommendations.
// Automatically navigates to Results on completion.
class CareerCompassAnalysingScreen extends ConsumerStatefulWidget {
  final String resumeText;
  final List answers; // List<CompassAnswer>

  const CareerCompassAnalysingScreen({
    super.key,
    required this.resumeText,
    required this.answers,
  });

  @override
  ConsumerState<CareerCompassAnalysingScreen> createState() =>
      _CareerCompassAnalysingScreenState();
}

class _CareerCompassAnalysingScreenState
    extends ConsumerState<CareerCompassAnalysingScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the AI call as soon as this screen mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnalysis());
  }

  Future<void> _startAnalysis() async {
    // Convert dynamic list to typed Map list
    final typedAnswers =
        widget.answers.map((e) => Map<String, String>.from(e)).toList();

    await ref.read(compassResultProvider.notifier).fetchRecommendations(
          resumeText: widget.resumeText,
          answers: typedAnswers,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Navigate to results when AI call completes successfully.
    ref.listen(compassResultProvider, (_, next) {
      if (next.domains != null) {
        context.pushReplacement(
          AppRoutes.careerCompassResults,
          extra: next.domains!,
        );
      }
    });

    final state = ref.watch(compassResultProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.sp32),
            child: state.errorMessage != null
                ? ErrorStateWidget(
                    message: state.errorMessage!,
                    onRetry: _startAnalysis,
                  )
                : _AnalysingView(),
          ),
        ),
      ),
    );
  }
}

// Animated loading view shown during analysis.
class _AnalysingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      'Reading your career preferences...',
      'Matching against 8 career domains...',
      'Calculating acceptance probabilities...',
      'Generating your personalised roadmap...',
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing compass icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.explore_rounded,
              size: 52, color: AppColors.primary),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(begin: 0.95, end: 1.05, duration: 1200.ms),
        const SizedBox(height: AppDimens.sp32),
        Text(
          AppStrings.careerCompassAnalysing,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(),
        const SizedBox(height: AppDimens.sp32),

        // Animated step list
        ...steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.sp12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sp12),
                  Text(
                    e.value,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: e.key * 600)),
            )),
      ],
    );
  }
}
