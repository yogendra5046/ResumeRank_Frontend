import 'package:hive/hive.dart';
import '../../domain/entities/history_item.dart';

part 'history_item_model.g.dart';

@HiveType(typeId: 0)
class HistoryItemModel extends HistoryItem {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get fileName => super.fileName;

  @HiveField(2)
  @override
  int get score => super.score;

  @HiveField(3)
  @override
  DateTime get date => super.date;

  @HiveField(4)
  @override
  List<String> get missingKeywords => super.missingKeywords;

  @HiveField(5)
  @override
  List<String> get suggestions => super.suggestions;

  @HiveField(6)
  @override
  int get percentile => super.percentile;

  @HiveField(7)
  @override
  String? get fullResultJson => super.fullResultJson;

  const HistoryItemModel({
    required super.id,
    required super.fileName,
    required super.score,
    required super.date,
    required super.missingKeywords,
    required super.suggestions,
    required super.percentile,
    super.fullResultJson,
  });

  factory HistoryItemModel.fromEntity(HistoryItem entity) {
    return HistoryItemModel(
      id: entity.id,
      fileName: entity.fileName,
      score: entity.score,
      date: entity.date,
      missingKeywords: entity.missingKeywords,
      suggestions: entity.suggestions,
      percentile: entity.percentile,
      fullResultJson: entity.fullResultJson,
    );
  }
}
