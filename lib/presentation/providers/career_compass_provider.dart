import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/career_domain.dart';
import '../../data/services/ai_service.dart';

// 18 open-ended questions covering personality, work style, interests,
// values, life goals, strengths, and environment preferences.
class CompassQuestion {
  final String id;
  final String question;
  final String hint;

  const CompassQuestion({
    required this.id,
    required this.question,
    required this.hint,
  });
}

const List<CompassQuestion> compassQuestions = [
  CompassQuestion(
    id: 'q1',
    question:
        'Tell me about yourself. What kind of person are you outside of work or study?',
    hint:
        'e.g. I am curious, love taking things apart, enjoy teaching friends...',
  ),
  CompassQuestion(
    id: 'q2',
    question: 'What activities make you lose track of time completely?',
    hint:
        'e.g. Writing code, sketching, reading about history, talking to people...',
  ),
  CompassQuestion(
    id: 'q3',
    question:
        'What are your top 3 strengths? Give a real example of each if you can.',
    hint:
        'e.g. I am very organised - I managed our college fest with 200 attendees...',
  ),
  CompassQuestion(
    id: 'q4',
    question: 'What do people usually come to you for help with?',
    hint:
        'e.g. Friends ask me to fix their laptops, or help write their cover letters...',
  ),
  CompassQuestion(
    id: 'q5',
    question:
        'Describe your ideal working environment. Where, how, and with whom do you work best?',
    hint:
        'e.g. Quiet room, alone, deep focus work - or busy office, lots of teamwork...',
  ),
  CompassQuestion(
    id: 'q6',
    question:
        'Do you prefer working on long deep projects or switching between many tasks? Why?',
    hint:
        'e.g. I like variety, I get bored easily - or I love diving deep into one thing...',
  ),
  CompassQuestion(
    id: 'q7',
    question:
        'How do you handle pressure and tight deadlines? Give an example.',
    hint:
        'e.g. I break tasks into small steps, stay calm - or I thrive under pressure...',
  ),
  CompassQuestion(
    id: 'q8',
    question:
        'Do you prefer working independently or leading/being part of a team?',
    hint:
        'e.g. I like to lead, I enjoy delegating - or I prefer executing on my own...',
  ),
  CompassQuestion(
    id: 'q9',
    question: 'What subjects, topics, or industries genuinely excite you? Why?',
    hint:
        'e.g. I love how AI is changing healthcare, or I am obsessed with finance and markets...',
  ),
  CompassQuestion(
    id: 'q10',
    question:
        'If money was not a concern, what would you spend your days doing professionally?',
    hint:
        'e.g. I would travel and write about cultures, or build apps that help people...',
  ),
  CompassQuestion(
    id: 'q11',
    question:
        'What kind of problems do you most enjoy solving? Practical, creative, analytical, social?',
    hint:
        'e.g. I love figuring out why systems break - or I enjoy persuading people...',
  ),
  CompassQuestion(
    id: 'q12',
    question: 'What does success mean to you personally in your career?',
    hint:
        'e.g. Financial freedom, making an impact, recognition, creative fulfilment...',
  ),
  CompassQuestion(
    id: 'q13',
    question:
        'What do you value most in a job? Rank and explain: salary, growth, purpose, flexibility, stability.',
    hint:
        'e.g. Growth first - I want to learn fast even if pay is lower at start...',
  ),
  CompassQuestion(
    id: 'q14',
    question:
        'Is it important to you that your work helps people or society? How so?',
    hint:
        'e.g. Yes, I want to work in education or health - or not necessarily, I prioritise craft...',
  ),
  CompassQuestion(
    id: 'q15',
    question:
        'What technical or professional skills have you built so far, even informally?',
    hint:
        'e.g. Self-taught Python, freelanced as a graphic designer, ran a small business...',
  ),
  CompassQuestion(
    id: 'q16',
    question: 'What subjects did you enjoy most in school or college, and why?',
    hint:
        'e.g. Loved maths because of patterns, or literature because of storytelling...',
  ),
  CompassQuestion(
    id: 'q17',
    question:
        'Where do you see yourself in 5 years? What does your ideal career look like?',
    hint:
        'e.g. Leading a product team, running my own agency, becoming a specialist in AI...',
  ),
  CompassQuestion(
    id: 'q18',
    question:
        'Are there any career paths you have already considered or ruled out? Why?',
    hint:
        'e.g. I ruled out pure sales, too much rejection. I am drawn to tech but not sure where...',
  ),
];

// Holds the user's free-text answers: questionId -> answer string.
class CompassAnswerState {
  final Map<String, String> answers;
  const CompassAnswerState({this.answers = const {}});

  CompassAnswerState withAnswer(String questionId, String answer) {
    return CompassAnswerState(answers: {...answers, questionId: answer});
  }

  static bool isValidAnswer(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 10) return false;

    // Split by whitespace to check word count
    final words = trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length < 2) return false;

    // Check unique character count (variety)
    final letters = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final uniqueLetters = letters.split('').toSet();
    if (uniqueLetters.length < 4) return false;

    // Vowel count check
    final vowelRegex = RegExp(r'[aeiouy]');
    if (!vowelRegex.hasMatch(letters)) return false;

    // Keyboard mash patterns
    final lower = trimmed.toLowerCase();
    final mashPatterns = [
      'asdf', 'sdfg', 'dfgh', 'fghj', 'ghjk', 'hjkl',
      'qwer', 'wert', 'erty', 'rtyu', 'tyui', 'yuio', 'uiop',
      'zxcv', 'xcvb', 'cvbn', 'vbnm'
    ];
    for (final pattern in mashPatterns) {
      if (lower.contains(pattern)) return false;
    }

    // Repeated words check
    if (words.length >= 3) {
      final uniqueWords = words.map((w) => w.toLowerCase()).toSet();
      if (uniqueWords.length == 1) return false;
    }

    return true;
  }

  bool isAnswered(String questionId) {
    final a = answers[questionId] ?? '';
    return isValidAnswer(a);
  }

  int get answeredCount =>
      compassQuestions.where((q) => isAnswered(q.id)).length;

  bool get canSubmit => answeredCount >= 12;

  List<Map<String, String>> toAnswerList() {
    return compassQuestions
        .where((q) => isAnswered(q.id))
        .map((q) => {
              'questionId': q.id,
              'question': q.question,
              'answer': answers[q.id]!.trim(),
            })
        .toList();
  }
}

// Riverpod 3.x: Notifier replaces StateNotifier.
class CompassAnswerNotifier extends Notifier<CompassAnswerState> {
  @override
  CompassAnswerState build() => const CompassAnswerState();

  void setAnswer(String questionId, String answer) {
    state = state.withAnswer(questionId, answer);
  }

  void reset() {
    state = const CompassAnswerState();
  }
}

final compassAnswerProvider =
    NotifierProvider<CompassAnswerNotifier, CompassAnswerState>(
        CompassAnswerNotifier.new);

// AI career recommendation state.
class CompassResultState {
  final bool isLoading;
  final List<CareerDomain>? domains;
  final String? errorMessage;

  const CompassResultState({
    this.isLoading = false,
    this.domains,
    this.errorMessage,
  });
}

// Riverpod 3.x: Notifier replaces StateNotifier.
class CompassResultNotifier extends Notifier<CompassResultState> {
  @override
  CompassResultState build() => const CompassResultState();

  Future<void> fetchRecommendations({
    required String resumeText,
    required List<Map<String, String>> answers,
  }) async {
    state = const CompassResultState(isLoading: true);
    try {
      final questionnaire = answers
          .map((a) => {
                'question': a['question'] ?? '',
                'answer': a['answer'] ?? '',
              })
          .toList();

      final result = await AiService.instance.runCareerCompass(
        resumeText: resumeText,
        questionnaire: questionnaire,
      );

      final recommendations = (result['recommendations'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map((rec) {
            final domainName = rec['domain'] as String? ?? 'Unknown';
            return CareerDomain(
              key: domainName.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
              label: domainName,
              matchPercent: (rec['match_pct'] as num?)?.toInt() ?? 0,
              acceptanceProbability: (rec['match_pct'] as num?)?.toInt() ?? 0,
              aiReasoning:
                  rec['reasoning'] as String? ?? 'No description available',
              requiredSkills:
                  List<String>.from(rec['required_skills'] as List? ?? []),
              certifications: List<String>.from(
                  rec['recommended_certifications'] as List? ?? []),
            );
          }).toList() ??
          [];

      state = CompassResultState(domains: recommendations);
    } catch (e) {
      state = CompassResultState(
          errorMessage: 'Failed to get recommendations: ${e.toString()}');
    }
  }

  void reset() => state = const CompassResultState();
}

final compassResultProvider =
    NotifierProvider<CompassResultNotifier, CompassResultState>(
        CompassResultNotifier.new);

// Riverpod 3.x: use NotifierProvider with simple Notifier for primitive state.
class ResumeTextNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final resumeTextProvider =
    NotifierProvider<ResumeTextNotifier, String?>(ResumeTextNotifier.new);
