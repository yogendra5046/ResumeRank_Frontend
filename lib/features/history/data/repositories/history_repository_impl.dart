import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<HistoryItem>>> getAllHistory() async {
    try {
      // 1. Try to fetch from remote to get latest sync
      try {
        final remoteItems = await remoteDataSource.getAllHistory();
        await localDataSource.clearHistory();
        for (var item in remoteItems) {
          await localDataSource.saveHistory(item);
        }
      } catch (e) {
        // Fallback to local if remote fails (e.g., offline)
      }
      final result = await localDataSource.getAllHistory();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveHistory(HistoryItem item) async {
    try {
      final id = await localDataSource.saveHistory(item);
      try {
        await remoteDataSource.saveHistory(item);
      } catch (e) {
        // Ignore remote save failure, item is cached locally
      }
      return Right(id);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistory(String id) async {
    try {
      await localDataSource.deleteHistory(id);
      try {
        await remoteDataSource.deleteHistory(id);
      } catch (e) {
        // Ignore remote failure
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      try {
        await remoteDataSource.clearHistory();
      } catch (e) {
        // Ignore remote failure
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
