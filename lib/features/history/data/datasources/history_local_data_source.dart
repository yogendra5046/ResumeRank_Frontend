import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/history_item.dart';
import '../../../../models/analysis_history.dart';

abstract class HistoryLocalDataSource {
  Future<List<HistoryItem>> getAllHistory();
  Future<String> saveHistory(HistoryItem item);
  Future<void> deleteHistory(String id);
  Future<void> clearHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const String boxName = 'analysis_history';

  @override
  Future<List<HistoryItem>> getAllHistory() async {
    final box = Hive.box<AnalysisHistory>(boxName);
    return box.values.map((e) => _mapToEntity(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<String> saveHistory(HistoryItem item) async {
    final box = Hive.box<AnalysisHistory>(boxName);
    final model = AnalysisHistory(
      id: item.id,
      fileName: item.fileName,
      score: item.score,
      date: item.date,
      missingKeywords: item.missingKeywords,
      suggestions: item.suggestions,
      percentile: item.percentile,
      fullResultJson: item.fullResultJson,
    );
    await box.put(model.id, model);
    return model.id;
  }

  @override
  Future<void> deleteHistory(String id) async {
    final box = Hive.box<AnalysisHistory>(boxName);
    await box.delete(id);
  }

  @override
  Future<void> clearHistory() async {
    final box = Hive.box<AnalysisHistory>(boxName);
    await box.clear();
  }

  HistoryItem _mapToEntity(AnalysisHistory model) {
    return HistoryItem(
      id: model.id,
      fileName: model.fileName,
      score: model.score,
      date: model.date,
      missingKeywords: model.missingKeywords,
      suggestions: model.suggestions,
      percentile: model.percentile,
      fullResultJson: model.fullResultJson,
    );
  }
}
