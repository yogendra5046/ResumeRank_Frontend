import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryItem>>> getAllHistory();
  Future<Either<Failure, String>> saveHistory(HistoryItem item);
  Future<Either<Failure, void>> deleteHistory(String id);
  Future<Either<Failure, void>> clearHistory();
}
