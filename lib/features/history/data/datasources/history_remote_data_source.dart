import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/history_item.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryItem>> getAllHistory();
  Future<void> saveHistory(HistoryItem item);
  Future<void> deleteHistory(String id);
  Future<void> clearHistory();
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;

  HistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HistoryItem>> getAllHistory() async {
    try {
      final response = await dio.get('/history/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => HistoryItem(
          id: item['id'],
          fileName: item['file_name'],
          date: DateTime.parse(item['date']),
          score: item['score'],
          percentile: item['percentile'],
          missingKeywords: List<String>.from(item['missing_keywords']),
          suggestions: List<String>.from(item['suggestions']),
          fullResultJson: item['full_result_json'],
        )).toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> saveHistory(HistoryItem item) async {
    try {
      await dio.post('/history/', data: {
        'id': item.id,
        'file_name': item.fileName,
        'date': item.date.toIso8601String(),
        'score': item.score,
        'percentile': item.percentile,
        'missing_keywords': item.missingKeywords,
        'suggestions': item.suggestions,
        'full_result_json': item.fullResultJson,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteHistory(String id) async {
    try {
      await dio.delete('/history/$id');
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      await dio.delete('/history/');
    } catch (e) {
      throw ServerException();
    }
  }
}
