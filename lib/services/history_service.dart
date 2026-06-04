import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/analysis_history.dart';
import '../models/analysis_history_adapter.dart';

class HistoryService {
  static const String boxName = 'analysis_history';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AnalysisHistoryAdapter());
    }
    await Hive.openBox<AnalysisHistory>(boxName);
  }

  static Box<AnalysisHistory> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        "History box not opened. Call HistoryService.init() first.",
      );
    }
    return Hive.box<AnalysisHistory>(boxName);
  }

  static Future<String> saveAnalysis({
    required String fileName,
    required int score,
    required int percentile,
    required List<String> missingKeywords,
    required List<String> suggestions,
    String? rawJson,
  }) async {
    if (!Hive.isBoxOpen(boxName)) await init();
    final history = AnalysisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      score: score,
      percentile: percentile,
      date: DateTime.now(),
      missingKeywords: missingKeywords,
      suggestions: suggestions,
      fullResultJson: rawJson,
    );
    await _box.put(history.id, history);
    return history.id;
  }

  static Future<void> updateResultJson(
    String id,
    Map<String, dynamic> updatedJson,
  ) async {
    if (!Hive.isBoxOpen(boxName)) await init();
    final history = _box.get(id);
    if (history != null) {
      // Merge logic: ensure we don't overwrite existing local data unless provided
      Map<String, dynamic> currentJson = {};
      if (history.fullResultJson != null) {
        currentJson = jsonDecode(history.fullResultJson!);
      }

      // Update with new fields
      currentJson.addAll(updatedJson);

      final updatedHistory = AnalysisHistory(
        id: history.id,
        fileName: history.fileName,
        score: history.score,
        percentile: history.percentile,
        date: history.date,
        missingKeywords: history.missingKeywords,
        suggestions: history.suggestions,
        fullResultJson: jsonEncode(currentJson),
      );

      await _box.put(id, updatedHistory);
    }
  }

  static List<AnalysisHistory> getAllHistory() {
    if (!Hive.isBoxOpen(boxName)) return [];
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> deleteHistory(String id) async {
    await _box.delete(id);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }
}
