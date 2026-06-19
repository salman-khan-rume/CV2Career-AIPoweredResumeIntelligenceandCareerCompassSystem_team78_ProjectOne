import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/analysis_result.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_routes.dart';
import '../widgets/app_card.dart';
import '../widgets/score_circle.dart';
import '../widgets/loading_error_widgets.dart';

// Screen 16: Analysis History.
// Shows all saved analyses for logged-in users with a score trend chart.
// Guests see a prompt to sign in.
class AnalysisHistoryScreen extends ConsumerWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestProvider);

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.historyTitle)),
        body: EmptyStateWidget(
          message: AppStrings.guestNoHistory,
          icon: Icons.lock_outline,
          action: ElevatedButton(
            onPressed: () => context.push(AppRoutes.login),
            child: const Text(AppStrings.signInNow),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historyTitle)),
      body: Consumer(
        builder: (context, ref, _) {
          final history = ref.watch(analysisHistoryProvider);

          return history.when(
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => ErrorStateWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(analysisHistoryProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const EmptyStateWidget(
                  message: AppStrings.historyEmpty,
                  icon: Icons.history_outlined,
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(analysisHistoryProvider),
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.paddingH),
                  children: [
                    // Score trend chart (shown when 2+ analyses exist)
                    if (items.length >= 2) ...[
                      _ScoreTrendChart(items: items).animate().fadeIn(),
                      const SizedBox(height: AppDimens.sp20),
                    ],

                    // History list
                    ...items.asMap().entries.map((e) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.sp12),
                          child: _HistoryCard(
                            result: e.value,
                            animDelay: e.key * 80,
                          ),
                        )),
                    const SizedBox(height: AppDimens.sp16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Line chart showing overall score trend across all analyses.
class _ScoreTrendChart extends StatelessWidget {
  final List<AnalysisResult> items;
  const _ScoreTrendChart({required this.items});

  @override
  Widget build(BuildContext context) {
    // Reverse to show oldest first on chart.
    final chronological = items.reversed.toList();

    final spots = chronological.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.overallScore.toDouble());
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.scoreTrend,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimens.sp16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A single history entry card.
class _HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final int animDelay;

  const _HistoryCard({required this.result, required this.animDelay});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.analysisResult, extra: result),
      child: Row(
        children: [
          ScoreCircle(
            score: result.overallScore,
            label: 'Score',
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'ATS: ${result.atsScore}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppUtils.scoreColor(result.atsScore),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppDimens.sp12),
                    Text(
                      '${result.suggestions.length} suggestions',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: animDelay))
        .slideX(begin: 0.04, end: 0);
  }
}
