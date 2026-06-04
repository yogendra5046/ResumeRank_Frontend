import 'dart:convert';
import 'package:hive/hive.dart';
import 'analysis_result.dart';

// Using manual adapter analysis_history_adapter.dart

class AnalysisHistory extends HiveObject {
  final String id;
  final String fileName;
  final int score;
  final DateTime date;
  final List<String> missingKeywords;
  final List<String> suggestions;
  final int percentile;
  final String? fullResultJson;

  AnalysisHistory({
    required this.id,
    required this.fileName,
    required this.score,
    required this.date,
    required this.missingKeywords,
    required this.suggestions,
    this.percentile = 50,
    this.fullResultJson,
  });

  AnalysisResult toAnalysisResult() {
    if (fullResultJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(fullResultJson!);
        return AnalysisResult.fromJson(decoded);
      } catch (e) {
        // Fallback if JSON is corrupted
      }
    }

    // Default fallback if full JSON is missing or invalid
    return AnalysisResult(
      score: score,
      percentile: percentile,
      suggestions: suggestions,
      missingKeywords: missingKeywords,
    );
  }
}
