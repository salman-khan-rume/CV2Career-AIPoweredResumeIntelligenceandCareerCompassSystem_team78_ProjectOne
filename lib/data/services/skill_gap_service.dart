import '../../core/constants/benchmark_data.dart';
import '../models/skill_gap.dart';

// Computes the skill gap between a user's resume skills and the benchmark data.
// TBD-3 resolution: benchmark data is hardcoded in BenchmarkData for v1.0.
// This service takes the list of skills extracted/identified by AI and compares
// them against the domain benchmark to produce a SkillGapReport.
class SkillGapService {
  // Generates a SkillGapReport for the given domain and user's identified skills.
  // [userSkills] is the list of skill strings extracted from the resume + AI analysis.
  // [domainKey] must match a key in BenchmarkData.domainSkills.
  SkillGapReport generateReport({
    required String domainKey,
    required List<String> userSkills,
  }) {
    final benchmarks = BenchmarkData.domainSkills[domainKey] ?? [];
    final domainLabel = BenchmarkData.domainLabels[domainKey] ?? domainKey;

    // Normalise user skills to lowercase for case-insensitive matching.
    final normalisedUserSkills = userSkills
        .map((s) => s.toLowerCase().trim())
        .toList();

    final items = benchmarks.map((benchmark) {
      final skill = benchmark['skill'] as String;
      final weight = benchmark['weight'] as int;
      final cert = benchmark['cert'] as String?;

      final status = _classifySkill(skill, normalisedUserSkills);

      return SkillGapItem(
        skill: skill,
        status: status,
        weight: weight,
        certSuggestion: status != SkillStatus.present ? cert : null,
      );
    }).toList();

    return SkillGapReport(
      domainKey: domainKey,
      domainLabel: domainLabel,
      skills: items,
    );
  }

  // Classifies a benchmark skill as present, partial, or missing
  // by checking how well it matches the user's normalised skill list.
  SkillStatus _classifySkill(String benchmarkSkill, List<String> userSkills) {
    final lowerBenchmark = benchmarkSkill.toLowerCase();

    // Split benchmark skill into keywords for partial matching.
    final keywords = lowerBenchmark
        .split(RegExp(r'[\s/&,()]+'))
        .where((k) => k.length > 2)
        .toList();

    // Full match: the exact skill or its alias appears in user skills.
    final exactMatch = userSkills.any((s) => s.contains(lowerBenchmark) || lowerBenchmark.contains(s));
    if (exactMatch) return SkillStatus.present;

    // Partial match: at least half of the skill's keywords appear in user skills.
    final matchedKeywords = keywords.where((keyword) =>
        userSkills.any((s) => s.contains(keyword))).length;

    if (keywords.isNotEmpty && matchedKeywords >= (keywords.length / 2).ceil()) {
      return SkillStatus.partial;
    }

    return SkillStatus.missing;
  }
}
