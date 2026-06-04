import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<Failure, List<HistoryItem>>> call() async {
    return await repository.getAllHistory();
  }
}

class SaveHistoryUseCase {
  final HistoryRepository repository;

  SaveHistoryUseCase(this.repository);

  Future<Either<Failure, String>> call(HistoryItem item) async {
    return await repository.saveHistory(item);
  }
}
