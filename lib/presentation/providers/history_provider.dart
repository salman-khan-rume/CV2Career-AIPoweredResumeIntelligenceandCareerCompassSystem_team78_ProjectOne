import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_result.dart';
import 'auth_provider.dart';

// Refresh counter - increment to force history reload.
// Riverpod 3.x: Notifier replaces StateProvider.
class HistoryRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final analysisHistoryRefreshTrigger =
    NotifierProvider<HistoryRefreshNotifier, int>(HistoryRefreshNotifier.new);

// Fetches analysis history for current logged-in user.
final analysisHistoryProvider =
    FutureProvider<List<AnalysisResult>>((ref) async {
  ref.watch(analysisHistoryRefreshTrigger);
  ref.watch(authStateProvider);

  final rawHistory =
      await ref.read(supabaseServiceProvider).getAnalysisHistory();

  return rawHistory
      .map((record) => AnalysisResult(
            id: record['id'] as String? ?? '',
            userId: record['user_id'] as String? ?? '',
            resumeFileName: record['file_name'] as String? ?? 'Resume',
            overallScore: (record['overall_score'] as num?)?.toInt() ?? 0,
            atsScore: (record['ats_score'] as num?)?.toInt() ?? 0,
            missingSections: [],
            weakLanguage: [],
            missingKeywords: [],
            suggestions: [],
          ))
      .toList();
});
