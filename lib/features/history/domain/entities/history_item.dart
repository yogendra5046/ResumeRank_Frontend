import 'dart:convert';
import 'package:equatable/equatable.dart';
import '../../../analysis/data/models/analysis_result_model.dart';
import '../../../analysis/domain/entities/analysis_result.dart';

class HistoryItem extends Equatable {
  final String id;
  final String fileName;
  final int score;
  final DateTime date;
  final List<String> missingKeywords;
  final List<String> suggestions;
  final int percentile;
  final String? fullResultJson;

  const HistoryItem({
    required this.id,
    required this.fileName,
    required this.score,
    required this.date,
    required this.missingKeywords,
    required this.suggestions,
    required this.percentile,
    this.fullResultJson,
  });

  @override
  List<Object?> get props => [
    id,
    fileName,
    score,
    date,
    missingKeywords,
    suggestions,
    percentile,
    fullResultJson,
  ];

  AnalysisResult toAnalysisResult() {
    if (fullResultJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(fullResultJson!);
        return AnalysisResultModel.fromJson(decoded);
      } catch (e) {
        // Fallback
      }
    }

    // Default fallback
    return AnalysisResult(
      score: score,
      grade: 'N/A',
      scoreBreakdown: const {},
      matchedSkills: const [],
      missingSkills: const [],
      skillGapChart: const [],
      criticalMissing: const [],
      suggestions: suggestions,
      gaps: const [],
      verbAnalysis: const {},
      jdKeywords: const [],
      rawResumeText: '',
      rawJdText: '',
      missingKeywords: missingKeywords,
      estimatedSalary: const {},
      professionalPersona: const {},
      careerGuidance: const {},
      percentile: percentile,
      jdRedFlags: const [],
      authenticityCheck: const AuthenticityCheck(
        score: 100,
        jdSimilarity: 0.0,
        risk: 'Low',
        details: [],
      ),
      roast: const [],
      negotiationScripts: const [],
      outreachTemplates: const [],
      cultureBio: '',
      gapProjects: const [],
      coverLetter: '',
      atsParse: const {},
      formatScore: const {},
    );
  }
}
