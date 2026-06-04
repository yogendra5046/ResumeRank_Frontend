class AnalysisResult {
  final int score;
  final String grade;
  final Map<String, dynamic> scoreBreakdown;
  final List<Map<String, dynamic>> matchedSkills;
  final List<Map<String, dynamic>> missingSkills;
  final List<SkillGapData> skillGapChart;
  final List<CriticalSkill> criticalMissing;
  final List<String> suggestions;
  final List<String> gaps;
  final Map<String, dynamic> verbAnalysis;
  final List<String> jdKeywords;
  final String rawResumeText;
  final String rawJdText;
  final List<String> missingKeywords;
  final Map<String, dynamic> estimatedSalary;
  final Map<String, dynamic> professionalPersona;
  final Map<String, dynamic> careerGuidance;
  final int percentile;
  final String? percentileText;
  final List<JDRedFlag> jdRedFlags;
  final AuthenticityCheck authenticityCheck;
  final List<String> roast;
  final List<Map<String, String>> negotiationScripts;
  final List<Map<String, String>> outreachTemplates;
  final String cultureBio;
  final List<Map<String, String>> gapProjects;
  final String coverLetter;
  final Map<String, dynamic>? rawJson;

  String? id;

  AnalysisResult({
    this.id,
    required this.score,
    this.grade = 'N/A',
    this.scoreBreakdown = const {
      'keywords': 0,
      'experience': 0,
      'verbs': 0,
      'format': 0,
    },
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.skillGapChart = const [],
    this.criticalMissing = const [],
    required this.suggestions,
    this.gaps = const [],
    this.verbAnalysis = const {'strong': 0, 'weak': 0, 'ratio': 0},
    this.jdKeywords = const [],
    this.rawResumeText = '',
    this.rawJdText = '',
    this.missingKeywords = const [],
    this.estimatedSalary = const {},
    this.professionalPersona = const {},
    this.careerGuidance = const {},
    this.percentile = 0,
    this.percentileText,
    this.jdRedFlags = const [],
    this.authenticityCheck = const AuthenticityCheck(
      score: 100,
      jdSimilarity: 0.0,
      risk: "Low",
      details: [],
    ),
    this.roast = const [],
    this.negotiationScripts = const [],
    this.outreachTemplates = const [],
    this.cultureBio = "",
    this.gapProjects = const [],
    this.coverLetter = "",
    this.atsParse = const {},
    this.formatScore = const {},
    this.rawJson,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['local_id'] as String?,
      score: (json['overall_score'] ?? json['score'] ?? 0) as int,
      grade: (json['grade'] ?? 'N/A') as String,
      scoreBreakdown: Map<String, dynamic>.from(json['score_breakdown'] ?? {}),
      matchedSkills: List<Map<String, dynamic>>.from(
        json['matched_skills'] ?? [],
      ),
      missingSkills: List<Map<String, dynamic>>.from(
        json['missing_skills'] ?? [],
      ),
      skillGapChart: (json['skill_gap_chart'] as List? ?? [])
          .map((item) => SkillGapData.fromJson(item))
          .toList(),
      criticalMissing: (json['critical_missing'] as List? ?? [])
          .map((item) => CriticalSkill.fromJson(item))
          .toList(),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      gaps: List<String>.from(json['gaps'] ?? []),
      verbAnalysis: Map<String, dynamic>.from(json['verb_analysis'] ?? {}),
      jdKeywords: List<String>.from(json['jd_keywords'] ?? []),
      rawResumeText: (json['raw_resume_text'] ?? '') as String,
      rawJdText: (json['raw_jd_text'] ?? '') as String,
      missingKeywords: List<String>.from(json['missing_keywords'] ?? []),
      estimatedSalary: Map<String, dynamic>.from(
        json['estimated_salary'] ?? {},
      ),
      professionalPersona: Map<String, dynamic>.from(
        json['professional_persona'] ?? {},
      ),
      careerGuidance: Map<String, dynamic>.from(json['career_guidance'] ?? {}),
      percentile: (json['percentile'] ?? 0) as int,
      percentileText: json['percentile_text'] as String?,
      jdRedFlags: (json['jd_red_flags'] as List? ?? [])
          .map((item) => JDRedFlag.fromJson(item))
          .toList(),
      authenticityCheck: AuthenticityCheck.fromJson(
        json['authenticity_check'] ?? {},
      ),
      roast: List<String>.from(json['roast'] ?? []),
      negotiationScripts: (json['negotiation_scripts'] as List? ?? [])
          .map((e) => Map<String, String>.from(e))
          .toList(),
      outreachTemplates: (json['outreach_templates'] as List? ?? [])
          .map((e) => Map<String, String>.from(e))
          .toList(),
      cultureBio: json['culture_bio'] ?? "",
      gapProjects: (json['gap_projects'] as List? ?? [])
          .map((e) => Map<String, String>.from(e))
          .toList(),
      coverLetter: json['cover_letter'] ?? "",
      atsParse: Map<String, dynamic>.from(json['ats_parse'] ?? {}),
      formatScore: Map<String, dynamic>.from(json['format'] ?? {}),
      rawJson: json,
    );
  }

  final Map<String, dynamic> atsParse;
  final Map<String, dynamic> formatScore;
}

class SkillGapData {
  final String name;
  final int matched;
  final int total;
  final int percent;
  final String status;

  SkillGapData({
    required this.name,
    required this.matched,
    required this.total,
    required this.percent,
    required this.status,
  });

  factory SkillGapData.fromJson(Map<String, dynamic> json) {
    return SkillGapData(
      name: (json['name'] ?? json['category'] ?? 'Unknown') as String,
      matched: (json['matched'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
      percent: (json['percent'] ?? 0) as int,
      status: (json['status'] ?? 'Good') as String,
    );
  }
}

class CriticalSkill {
  final String name;
  final int weight;
  final String jobs;
  final int points;

  CriticalSkill({
    required this.name,
    required this.weight,
    required this.jobs,
    required this.points,
  });

  factory CriticalSkill.fromJson(Map<String, dynamic> json) {
    return CriticalSkill(
      name: (json['name'] ?? '') as String,
      weight: (json['weight'] ?? 0) as int,
      jobs: (json['jobs'] ?? '0%') as String,
      points: (json['points'] ?? 0) as int,
    );
  }
}

class JDRedFlag {
  final String flag;
  final String description;
  final String severity;

  JDRedFlag({
    required this.flag,
    required this.description,
    required this.severity,
  });

  factory JDRedFlag.fromJson(Map<String, dynamic> json) {
    return JDRedFlag(
      flag: (json['flag'] ?? 'Flag') as String,
      description: (json['description'] ?? '') as String,
      severity: (json['severity'] ?? 'Medium') as String,
    );
  }
}

class AuthenticityCheck {
  final int score;
  final double jdSimilarity;
  final String risk;
  final List<String> details;

  const AuthenticityCheck({
    required this.score,
    required this.jdSimilarity,
    required this.risk,
    required this.details,
  });

  factory AuthenticityCheck.fromJson(Map<String, dynamic> json) {
    return AuthenticityCheck(
      score: (json['score'] ?? 100) as int,
      jdSimilarity: (json['jd_similarity'] ?? 0.0) as double,
      risk: (json['plagiarism_risk'] ?? 'Low') as String,
      details: List<String>.from(json['details'] ?? []),
    );
  }
}
