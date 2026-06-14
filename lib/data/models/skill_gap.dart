// Status of a single skill relative to industry benchmark.
// Per SRS FR-6.1: Present, Partially Present, or Missing.
enum SkillStatus { present, partial, missing }

// A single skill entry in the gap analysis.
class SkillGapItem {
  final String skill;
  final SkillStatus status;
  final int weight;           // Impact on acceptance score (1-10)
  final String? certSuggestion; // Recommended certification if missing/partial

  const SkillGapItem({
    required this.skill,
    required this.status,
    required this.weight,
    this.certSuggestion,
  });
}

// Full skill gap report for one career domain.
// Per SRS FR-6.2 and FR-6.3.
class SkillGapReport {
  final String domainKey;
  final String domainLabel;
  final List<SkillGapItem> skills;

  const SkillGapReport({
    required this.domainKey,
    required this.domainLabel,
    required this.skills,
  });

  // Convenience getters for each skill status category.
  List<SkillGapItem> get presentSkills =>
      skills.where((s) => s.status == SkillStatus.present).toList();

  List<SkillGapItem> get partialSkills =>
      skills.where((s) => s.status == SkillStatus.partial).toList();

  List<SkillGapItem> get missingSkills =>
      skills.where((s) => s.status == SkillStatus.missing).toList();

  // Returns missing + partial skills sorted by weight descending (highest impact first).
  // This is the improvement roadmap per FR-6.3.
  List<SkillGapItem> get roadmap {
    final items = [...partialSkills, ...missingSkills];
    items.sort((a, b) => b.weight.compareTo(a.weight));
    return items;
  }

  // Completeness score: present / total (expressed as 0-100).
  int get completenessPercent {
    if (skills.isEmpty) return 0;
    final presentCount = presentSkills.length + (partialSkills.length * 0.5);
    return ((presentCount / skills.length) * 100).round();
  }
}
