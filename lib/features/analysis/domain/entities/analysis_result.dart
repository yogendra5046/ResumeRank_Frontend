import 'package:equatable/equatable.dart';

class AnalysisResult extends Equatable {
  final String? id;
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
  final Map<String, dynamic> atsParse;
  final Map<String, dynamic> formatScore;

  const AnalysisResult({
    this.id,
    required this.score,
    required this.grade,
    required this.scoreBreakdown,
    required this.matchedSkills,
    required this.missingSkills,
    required this.skillGapChart,
    required this.criticalMissing,
    required this.suggestions,
    required this.gaps,
    required this.verbAnalysis,
    required this.jdKeywords,
    required this.rawResumeText,
    required this.rawJdText,
    required this.missingKeywords,
    required this.estimatedSalary,
    required this.professionalPersona,
    required this.careerGuidance,
    required this.percentile,
    this.percentileText,
    required this.jdRedFlags,
    required this.authenticityCheck,
    required this.roast,
    required this.negotiationScripts,
    required this.outreachTemplates,
    required this.cultureBio,
    required this.gapProjects,
    required this.coverLetter,
    required this.atsParse,
    required this.formatScore,
  });

  @override
  List<Object?> get props => [
    id,
    score,
    grade,
    scoreBreakdown,
    matchedSkills,
    missingSkills,
    skillGapChart,
    criticalMissing,
    suggestions,
    gaps,
    verbAnalysis,
    jdKeywords,
    rawResumeText,
    rawJdText,
    missingKeywords,
    estimatedSalary,
    professionalPersona,
    careerGuidance,
    percentile,
    percentileText,
    jdRedFlags,
    authenticityCheck,
    roast,
    negotiationScripts,
    outreachTemplates,
    cultureBio,
    gapProjects,
    coverLetter,
    atsParse,
    formatScore,
  ];
}

class SkillGapData extends Equatable {
  final String name;
  final int matched;
  final int total;
  final int percent;
  final String status;

  const SkillGapData({
    required this.name,
    required this.matched,
    required this.total,
    required this.percent,
    required this.status,
  });

  @override
  List<Object?> get props => [name, matched, total, percent, status];
}

class CriticalSkill extends Equatable {
  final String name;
  final int weight;
  final String jobs;
  final int points;

  const CriticalSkill({
    required this.name,
    required this.weight,
    required this.jobs,
    required this.points,
  });

  @override
  List<Object?> get props => [name, weight, jobs, points];
}

class JDRedFlag extends Equatable {
  final String flag;
  final String description;
  final String severity;

  const JDRedFlag({
    required this.flag,
    required this.description,
    required this.severity,
  });

  @override
  List<Object?> get props => [flag, description, severity];
}

class AuthenticityCheck extends Equatable {
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

  @override
  List<Object?> get props => [score, jdSimilarity, risk, details];
}
