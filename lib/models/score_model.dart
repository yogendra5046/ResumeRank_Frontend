class ScoreResponse {
  final int overallScore;
  final String grade;
  final ScoreDetail impact;
  final ScoreDetail format;
  final SkillGapDetail skillGap;
  final ScoreDetail atsParse;
  final bool fromCache;
  final String rawResumeText;
  final String rawJdText;

  ScoreResponse({
    required this.overallScore,
    required this.grade,
    required this.impact,
    required this.format,
    required this.skillGap,
    required this.atsParse,
    this.fromCache = false,
    this.rawResumeText = '',
    this.rawJdText = '',
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    return ScoreResponse(
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 0,
      grade: json['grade'] as String? ?? 'D',
      impact: ScoreDetail.fromJson(json['impact'] ?? {}),
      format: ScoreDetail.fromJson(json['format'] ?? {}),
      skillGap: SkillGapDetail.fromJson(json['skill_gap'] ?? {}),
      atsParse: ScoreDetail.fromJson(json['ats_parse'] ?? {}),
      fromCache: json['from_cache'] as bool? ?? false,
      rawResumeText: json['raw_resume_text'] as String? ?? '',
      rawJdText: json['raw_jd_text'] as String? ?? '',
    );
  }
}

class ScoreDetail {
  final int score;
  final List<String> details;
  final String? debugText;

  ScoreDetail({required this.score, required this.details, this.debugText});

  factory ScoreDetail.fromJson(Map<String, dynamic> json) {
    return ScoreDetail(
      score: (json['score'] as num?)?.toInt() ?? 0,
      details: List<String>.from(json['details'] ?? []),
      debugText: json['debug_text'] as String?,
    );
  }
}

class SkillGapDetail {
  final int matchPercent;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<SkillGraphItem> skillGraphData;

  SkillGapDetail({
    required this.matchPercent,
    required this.matchedSkills,
    required this.missingSkills,
    required this.skillGraphData,
  });

  factory SkillGapDetail.fromJson(Map<String, dynamic> json) {
    return SkillGapDetail(
      matchPercent: (json['match_percent'] as num?)?.toInt() ?? 0,
      matchedSkills: List<String>.from(json['matched_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      skillGraphData:
          (json['skill_graph_data'] as List?)
              ?.map((e) => SkillGraphItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SkillGraphItem {
  final String skill;
  final String status;
  final int jdCount;
  final int resumeCount;

  SkillGraphItem({
    required this.skill,
    required this.status,
    required this.jdCount,
    required this.resumeCount,
  });

  factory SkillGraphItem.fromJson(Map<String, dynamic> json) {
    return SkillGraphItem(
      skill: json['skill'] as String? ?? '',
      status: json['status'] as String? ?? '',
      jdCount: (json['jd_count'] as num?)?.toInt() ?? 0,
      resumeCount: (json['resume_count'] as num?)?.toInt() ?? 0,
    );
  }
}
