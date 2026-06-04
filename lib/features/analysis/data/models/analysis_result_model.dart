import '../../domain/entities/analysis_result.dart';
import '../../../../models/analysis_result.dart' as legacy;

class AnalysisResultModel extends AnalysisResult {
  const AnalysisResultModel({
    super.id,
    required super.score,
    required super.grade,
    required super.scoreBreakdown,
    required super.matchedSkills,
    required super.missingSkills,
    required super.skillGapChart,
    required super.criticalMissing,
    required super.suggestions,
    required super.gaps,
    required super.verbAnalysis,
    required super.jdKeywords,
    required super.rawResumeText,
    required super.rawJdText,
    required super.missingKeywords,
    required super.estimatedSalary,
    required super.professionalPersona,
    required super.careerGuidance,
    required super.percentile,
    super.percentileText,
    required super.jdRedFlags,
    required super.authenticityCheck,
    required super.roast,
    required super.negotiationScripts,
    required super.outreachTemplates,
    required super.cultureBio,
    required super.gapProjects,
    required super.coverLetter,
    required super.atsParse,
    required super.formatScore,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
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
          .map((item) => SkillGapDataModel.fromJson(item))
          .toList(),
      criticalMissing: (json['critical_missing'] as List? ?? [])
          .map((item) => CriticalSkillModel.fromJson(item))
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
          .map((item) => JDRedFlagModel.fromJson(item))
          .toList(),
      authenticityCheck: AuthenticityCheckModel.fromJson(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': id,
      'overall_score': score,
      'grade': grade,
      'score_breakdown': scoreBreakdown,
      'matched_skills': matchedSkills,
      'missing_skills': missingSkills,
      'skill_gap_chart': skillGapChart
          .map((e) => (e as SkillGapDataModel).toJson())
          .toList(),
      'critical_missing': criticalMissing
          .map((e) => (e as CriticalSkillModel).toJson())
          .toList(),
      'suggestions': suggestions,
      'gaps': gaps,
      'verb_analysis': verbAnalysis,
      'jd_keywords': jdKeywords,
      'raw_resume_text': rawResumeText,
      'raw_jd_text': rawJdText,
      'missing_keywords': missingKeywords,
      'estimated_salary': estimatedSalary,
      'professional_persona': professionalPersona,
      'career_guidance': careerGuidance,
      'percentile': percentile,
      'percentile_text': percentileText,
      'jd_red_flags': jdRedFlags
          .map((e) => (e as JDRedFlagModel).toJson())
          .toList(),
      'authenticity_check': (authenticityCheck as AuthenticityCheckModel)
          .toJson(),
      'roast': roast,
      'negotiation_scripts': negotiationScripts,
      'outreach_templates': outreachTemplates,
      'culture_bio': cultureBio,
      'gap_projects': gapProjects,
      'cover_letter': coverLetter,
      'ats_parse': atsParse,
      'format': formatScore,
    };
  }

  legacy.AnalysisResult toOldModel() {
    return legacy.AnalysisResult(
      id: id,
      score: score,
      grade: grade,
      scoreBreakdown: scoreBreakdown,
      matchedSkills: matchedSkills,
      missingSkills: missingSkills,
      skillGapChart: skillGapChart
          .map(
            (e) => legacy.SkillGapData(
              name: e.name,
              matched: e.matched,
              total: e.total,
              percent: e.percent,
              status: e.status,
            ),
          )
          .toList(),
      criticalMissing: criticalMissing
          .map(
            (e) => legacy.CriticalSkill(
              name: e.name,
              weight: e.weight,
              jobs: e.jobs,
              points: e.points,
            ),
          )
          .toList(),
      suggestions: suggestions,
      gaps: gaps,
      verbAnalysis: verbAnalysis,
      jdKeywords: jdKeywords,
      rawResumeText: rawResumeText,
      rawJdText: rawJdText,
      missingKeywords: missingKeywords,
      estimatedSalary: estimatedSalary,
      professionalPersona: professionalPersona,
      careerGuidance: careerGuidance,
      percentile: percentile,
      percentileText: percentileText,
      jdRedFlags: jdRedFlags
          .map(
            (e) => legacy.JDRedFlag(
              flag: e.flag,
              description: e.description,
              severity: e.severity,
            ),
          )
          .toList(),
      authenticityCheck: legacy.AuthenticityCheck(
        score: authenticityCheck.score,
        jdSimilarity: authenticityCheck.jdSimilarity,
        risk: authenticityCheck.risk,
        details: authenticityCheck.details,
      ),
      roast: roast,
      negotiationScripts: negotiationScripts,
      outreachTemplates: outreachTemplates,
      cultureBio: cultureBio,
      gapProjects: gapProjects,
      coverLetter: coverLetter,
      atsParse: atsParse,
      formatScore: formatScore,
      rawJson: toJson(),
    );
  }
}

class SkillGapDataModel extends SkillGapData {
  const SkillGapDataModel({
    required super.name,
    required super.matched,
    required super.total,
    required super.percent,
    required super.status,
  });

  factory SkillGapDataModel.fromJson(Map<String, dynamic> json) {
    return SkillGapDataModel(
      name: (json['name'] ?? json['category'] ?? 'Unknown') as String,
      matched: (json['matched'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
      percent: (json['percent'] ?? 0) as int,
      status: (json['status'] ?? 'Good') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'matched': matched,
      'total': total,
      'percent': percent,
      'status': status,
    };
  }
}

class CriticalSkillModel extends CriticalSkill {
  const CriticalSkillModel({
    required super.name,
    required super.weight,
    required super.jobs,
    required super.points,
  });

  factory CriticalSkillModel.fromJson(Map<String, dynamic> json) {
    return CriticalSkillModel(
      name: (json['name'] ?? '') as String,
      weight: (json['weight'] ?? 0) as int,
      jobs: (json['jobs'] ?? '0%') as String,
      points: (json['points'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'weight': weight, 'jobs': jobs, 'points': points};
  }
}

class JDRedFlagModel extends JDRedFlag {
  const JDRedFlagModel({
    required super.flag,
    required super.description,
    required super.severity,
  });

  factory JDRedFlagModel.fromJson(Map<String, dynamic> json) {
    return JDRedFlagModel(
      flag: (json['flag'] ?? 'Flag') as String,
      description: (json['description'] ?? '') as String,
      severity: (json['severity'] ?? 'Medium') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'flag': flag, 'description': description, 'severity': severity};
  }
}

class AuthenticityCheckModel extends AuthenticityCheck {
  const AuthenticityCheckModel({
    required super.score,
    required super.jdSimilarity,
    required super.risk,
    required super.details,
  });

  factory AuthenticityCheckModel.fromJson(Map<String, dynamic> json) {
    return AuthenticityCheckModel(
      score: (json['score'] ?? 100) as int,
      jdSimilarity: (json['jd_similarity'] ?? 0.0) as double,
      risk: (json['plagiarism_risk'] ?? 'Low') as String,
      details: List<String>.from(json['details'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'plagiarism_risk': risk,
      'jd_similarity': jdSimilarity,
      'details': details,
    };
  }
}
