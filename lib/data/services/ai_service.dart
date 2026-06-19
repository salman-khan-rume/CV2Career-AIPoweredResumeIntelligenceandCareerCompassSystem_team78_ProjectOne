import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

/// All AI calls go through this service ONLY.
/// Never call Groq directly from a screen or provider.
/// To swap AI provider: replace _callGroq() internals only; all callers stay unchanged.
class AiService {
  AiService._();
  static final AiService instance = AiService._();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model =
      'llama-3.3-70b-versatile'; // best free tier model
  static const double _temperature = 0.3; // low = consistent structured output

  // ── CORE CALL (retry + timeout) ─────────────────────────────────────────

  /// Sends [prompt] to Groq with retry and exponential backoff.
  /// Returns decoded JSON map. Throws descriptive error on failure.
  Future<Map<String, dynamic>> _callGroq(String prompt) async {
    int attempt = 0;
    Duration delay = const Duration(seconds: 2);

    while (attempt < AppConstants.aiMaxRetries) {
      try {
        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConstants.groqApiKey}',
              },
              body: jsonEncode({
                'model': _model,
                'temperature': _temperature,
                'messages': [
                  {
                    'role': 'system',
                    'content':
                        'You are a helpful assistant. Always respond with valid JSON only. No explanation, no markdown, no code fences.',
                  },
                  {
                    'role': 'user',
                    'content': prompt,
                  },
                ],
              }),
            )
            .timeout(const Duration(seconds: AppConstants.aiTimeoutSeconds));

        if (response.statusCode != 200) {
          throw Exception(
              'Groq API error ${response.statusCode}: ${response.body}');
        }

        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final content = decoded['choices'][0]['message']['content'] as String;

        // Strip markdown fences if model adds them anyway
        final clean = content
            .replaceAll(RegExp(r'```json\s*'), '')
            .replaceAll(RegExp(r'```\s*'), '')
            .trim();

        return jsonDecode(clean) as Map<String, dynamic>;
      } on TimeoutException {
        attempt++;
        if (attempt >= AppConstants.aiMaxRetries) {
          throw Exception(
              'AI request timed out after ${AppConstants.aiMaxRetries} attempts.');
        }
        await Future.delayed(delay);
        delay *= 2;
      } catch (e) {
        attempt++;
        if (attempt >= AppConstants.aiMaxRetries) rethrow;
        await Future.delayed(delay);
        delay *= 2;
      }
    }

    throw Exception(
        'AI service failed after ${AppConstants.aiMaxRetries} retries.');
  }

  // ── 1. RESUME ANALYZER ──────────────────────────────────────────────────

  /// Analyze resume text and return structured scoring + suggestions.
  Future<Map<String, dynamic>> analyzeResume(String resumeText) async {
    final prompt = '''
You are an expert resume reviewer and ATS specialist.
Analyze the resume below and respond ONLY with a valid JSON object.
No explanation, no markdown, just the JSON.

Resume:
"""
$resumeText
"""

Required JSON structure:
{
  "overall_score": <int 0-100>,
  "ats_score": <int 0-100>,
  "missing_sections": [<string>, ...],
  "weak_language": [<string>, ...],
  "missing_keywords": [<string>, ...],
  "suggestions": [
    {"type": "Add"|"Remove"|"Improve", "text": <string>},
    ...
  ]
}

Scoring guide:
- overall_score: holistic quality (clarity, completeness, impact)
- ats_score: keyword density, standard section headings, no tables/graphics
- missing_sections: e.g. ["Summary", "Certifications", "LinkedIn URL"]
- weak_language: vague phrases found e.g. ["responsible for", "worked on"]
- missing_keywords: industry-standard keywords absent from resume
- suggestions: 5 to 10 actionable items, mix of Add/Remove/Improve
''';

    return await _callGroq(prompt);
  }

  // ── 2. CAREER COMPASS ───────────────────────────────────────────────────

  /// Given resume text + questionnaire answers, recommend career domains.
  Future<Map<String, dynamic>> runCareerCompass({
    required String resumeText,
    required List<Map<String, dynamic>> questionnaire,
  }) async {
    final qFormatted = questionnaire
        .map((q) => 'Q: ${q['question']}\nA: ${q['answer']}')
        .join('\n\n');

    final prompt = '''
You are a career guidance expert.
Based on the resume and questionnaire answers below, recommend the best career domains.
Respond ONLY with a valid JSON object. No explanation, no markdown.

Resume:
"""
$resumeText
"""

Questionnaire:
"""
$qFormatted
"""

Required JSON structure:
{
  "recommendations": [
    {
      "domain": <string>,
      "match_pct": <int 0-100>,
      "reasoning": <string, 1-2 sentences>,
      "required_skills": [<string>, ...],
      "recommended_certifications": [<string>, ...]
    }
  ]
}

Rules:
- Return 5 to 10 domains, sorted by match_pct descending
- reasoning must reference specific resume content or questionnaire answers
- required_skills: top 5 skills for that domain
- recommended_certifications: up to 3 real, obtainable certifications
''';

    return await _callGroq(prompt);
  }

  // ── 3. SKILL GAP ANALYZER ───────────────────────────────────────────────

  /// Compare resume skills against a chosen career domain.
  Future<Map<String, dynamic>> analyzeSkillGap({
    required String resumeText,
    required String careerDomain,
  }) async {
    final prompt = '''
You are a technical skills assessor.
Compare the resume below against the requirements of a "$careerDomain" career.
Respond ONLY with a valid JSON object. No explanation, no markdown.

Resume:
"""
$resumeText
"""

Required JSON structure:
{
  "acceptance_score": <int 0-100>,
  "skills_present": [<string>, ...],
  "skills_partial": [<string>, ...],
  "skills_missing": [<string>, ...],
  "roadmap": [
    {
      "skill": <string>,
      "priority": "High"|"Medium"|"Low",
      "resources": [<string URL or course name>, ...],
      "certifications": [<string>, ...]
    }
  ]
}

Rules:
- acceptance_score: how competitive this resume is for "$careerDomain" right now
- skills_present: clearly demonstrated in resume
- skills_partial: mentioned but needs strengthening
- skills_missing: required for domain but absent
- roadmap: only for skills_partial and skills_missing, sorted by priority (High first)
- resources: real, named courses (Coursera, Udemy, freeCodeCamp, etc.)
''';

    return await _callGroq(prompt);
  }

  // ── 4. DYNAMIC SKILL GAP WITH JOB DESCRIPTION ───────────────────────────

  /// Compare resume skills against a specific Job Description text.
  Future<Map<String, dynamic>> analyzeSkillGapWithJD({
    required String resumeText,
    required String jobDescriptionText,
  }) async {
    final prompt = '''
You are a senior recruiter and technical skills assessor.
Compare the resume below against the requirements of the provided Job Description.
Respond ONLY with a valid JSON object. No explanation, no markdown.

Resume:
"""
$resumeText
"""

Job Description:
"""
$jobDescriptionText
"""

Required JSON structure:
{
  "acceptance_score": <int 0-100>,
  "skills_present": [<string>, ...],
  "skills_partial": [<string>, ...],
  "skills_missing": [<string>, ...],
  "roadmap": [
    {
      "skill": <string>,
      "priority": "High"|"Medium"|"Low",
      "resources": [<string URL or course name>, ...],
      "certifications": [<string>, ...]
    }
  ]
}

Rules:
- acceptance_score: how well the resume matches the job description qualifications (0 to 100)
- skills_present: skills from the job description that are clearly demonstrated in the resume
- skills_partial: skills from the job description that are mentioned in the resume but need strengthening or more experience
- skills_missing: key requirements or skills from the job description that are completely absent from the resume
- roadmap: actionable development plan for the skills listed in skills_partial and skills_missing, sorted by priority (High first)
- resources: real, named learning resources or online courses (e.g. Coursera, Udemy, LinkedIn Learning, freeCodeCamp)
''';

    return await _callGroq(prompt);
  }

  // ── 5. CAREER ROADMAP GENERATOR ──────────────────────────────────────────

  /// Create a step-by-step career path from user target goal and current background.
  Future<Map<String, dynamic>> generateCareerRoadmap({
    required String targetRole,
    required String currentCondition,
  }) async {
    final prompt = '''
You are a professional career coach and AI roadmap planner.
Create a structured step-by-step career roadmap guiding a user from their current condition to their desired target role.
For each step/phase, provide actionable milestones, recommended learning topics, and real, clickable resource URLs (e.g. specific courses on Coursera, Udemy, edX, or official documentation, guides, or roadmaps like roadmap.sh, MDN Web Docs, etc.).
Respond ONLY with a valid JSON object. No explanation, no markdown, just the JSON.

Desired Target Role:
"""
$targetRole
"""

Current Scenario/Condition:
"""
$currentCondition
"""

Required JSON structure:
{
  "target_role": "<string>",
  "current_condition": "<string>",
  "estimated_timeline": "<string, e.g. '6-12 Months'>",
  "phases": [
    {
      "phase_number": <int>,
      "title": "<string>",
      "description": "<string>",
      "duration": "<string, e.g. 'Months 1-2'>",
      "milestones": ["<string>", ...],
      "resources": [
        {
          "name": "<string, e.g. 'Coursera: Meta Front-End Developer Professional Certificate'>",
          "url": "<string URL, must be a real valid clickable URL, e.g. https://www.coursera.org/... or similar>"
        },
        ...
      ]
    },
    ...
  ]
}

Rules:
- Provide 3 to 5 realistic, sequential phases.
- Ensure all resources contain a real, valid URL. Do not use placeholders like "https://example.com". Use actual URLs of education providers, documentation, or relevant sites.
''';

    return await _callGroq(prompt);
  }
}
