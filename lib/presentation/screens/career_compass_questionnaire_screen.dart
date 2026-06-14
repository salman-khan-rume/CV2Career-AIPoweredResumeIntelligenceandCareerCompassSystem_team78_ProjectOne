import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../providers/app_routes.dart';
import '../providers/career_compass_provider.dart';
import '../widgets/app_card.dart';

// Screen 11: Career Compass Questionnaire.
// 18 open-ended free-text questions, one per page.
// User can skip individual questions but needs 12+ answered to proceed.
class CareerCompassQuestionnaireScreen extends ConsumerStatefulWidget {
  const CareerCompassQuestionnaireScreen({super.key});

  @override
  ConsumerState<CareerCompassQuestionnaireScreen> createState() =>
      _CareerCompassQuestionnaireScreenState();
}

class _CareerCompassQuestionnaireScreenState
    extends ConsumerState<CareerCompassQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // One TextEditingController per question, persists across page changes.
  final List<TextEditingController> _controllers = List.generate(
    compassQuestions.length,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveCurrentAnswer() {
    final q = compassQuestions[_currentIndex];
    final text = _controllers[_currentIndex].text;
    ref.read(compassAnswerProvider.notifier).setAnswer(q.id, text);
  }

  void _goTo(int index) {
    _saveCurrentAnswer();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentIndex < compassQuestions.length - 1) {
      _goTo(_currentIndex + 1);
    } else {
      _saveCurrentAnswer();
      _submit();
    }
  }

  void _back() {
    if (_currentIndex > 0) _goTo(_currentIndex - 1);
  }

  void _submit() {
    final answers = ref.read(compassAnswerProvider);
    if (!answers.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer at least 12 questions (${answers.answeredCount} answered so far).',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final resumeText = ref.read(resumeTextProvider) ?? '';
    context.push(AppRoutes.careerCompassAnalysing, extra: {
      'resumeText': resumeText,
      'answers': answers.toAnswerList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(compassAnswerProvider);
    final total = compassQuestions.length;
    final answered = answers.answeredCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.careerCompassTitle),
        automaticallyImplyLeading: false,
        actions: [
          // Show submit button when enough questions answered
          if (answers.canSubmit)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.sp8),
              child: TextButton(
                onPressed: () {
                  _saveCurrentAnswer();
                  _submit();
                },
                child: const Text('Submit'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top progress bar + counter
            _ProgressHeader(
              current: _currentIndex + 1,
              total: total,
              answered: answered,
            ),

            // Question pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // nav via buttons only
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: compassQuestions.length,
                itemBuilder: (context, index) {
                  final q = compassQuestions[index];
                  return _QuestionPage(
                    question: q,
                    controller: _controllers[index],
                    questionNumber: index + 1,
                    total: total,
                  );
                },
              ),
            ),

            // Bottom nav bar
            _BottomNav(
              currentIndex: _currentIndex,
              total: total,
              onBack: _currentIndex > 0 ? _back : null,
              onNext: _next,
              isLast: _currentIndex == total - 1,
              canSubmit: answers.canSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// Progress header with linear bar + "X of Y answered" counter.
class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final int answered;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.answered,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp12,
        AppDimens.paddingH,
        AppDimens.sp8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$answered answered',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: answered >= 12
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sp6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 6,
              backgroundColor: AppColors.border,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Single question page with large text input.
class _QuestionPage extends StatelessWidget {
  final CompassQuestion question;
  final TextEditingController controller;
  final int questionNumber;
  final int total;

  const _QuestionPage({
    required this.question,
    required this.controller,
    required this.questionNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.sp8),

          // Section tag (derived from question ID grouping)
          _SectionTag(questionNumber: questionNumber),
          const SizedBox(height: AppDimens.sp12),

          // Question text
          Text(
            question.question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.4,
                ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
          const SizedBox(height: AppDimens.sp8),

          // Optional label
          Text(
            'Optional - skip if not applicable',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: AppDimens.sp20),

          // Free-text input
          TextField(
            controller: controller,
            maxLines: 6,
            minLines: 4,
            maxLength: 600,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            decoration: InputDecoration(
              hintText: question.hint,
              hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDisabled,
                    height: 1.5,
                  ),
              alignLabelWithHint: true,
              counterStyle: Theme.of(context).textTheme.bodySmall,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: AppDimens.sp16),

          // Tip card
          AppCard(
            color: AppColors.primarySurface,
            padding: const EdgeInsets.all(AppDimens.sp12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: AppDimens.sp8),
                Expanded(
                  child: Text(
                    'Be honest and specific. The more detail you give, '
                    'the more accurate your career matches will be.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }
}

// Small pill showing which life area the question covers.
class _SectionTag extends StatelessWidget {
  final int questionNumber;
  const _SectionTag({required this.questionNumber});

  // Group questions into named sections.
  String get _label {
    if (questionNumber <= 4) return 'Who You Are';
    if (questionNumber <= 8) return 'Work Style';
    if (questionNumber <= 11) return 'Interests';
    if (questionNumber <= 14) return 'Values';
    if (questionNumber <= 16) return 'Skills';
    return 'Career Direction';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        _label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// Prev / Next / Submit navigation bar at the bottom.
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;
  final bool canSubmit;

  const _BottomNav({
    required this.currentIndex,
    required this.total,
    required this.onBack,
    required this.onNext,
    required this.isLast,
    required this.canSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingH,
        AppDimens.sp12,
        AppDimens.paddingH,
        AppDimens.sp20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Back button
          if (onBack != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppDimens.buttonHeightMd),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: AppDimens.sp12),

          // Next / Submit button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onNext,
              icon: Icon(
                isLast ? Icons.auto_awesome : Icons.arrow_forward,
                size: 16,
              ),
              label: Text(isLast ? 'Find My Career Path' : 'Next'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, AppDimens.buttonHeightMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
