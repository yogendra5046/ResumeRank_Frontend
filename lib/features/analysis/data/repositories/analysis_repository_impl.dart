import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_data_source.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDataSource remoteDataSource;

  AnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AnalysisResult>> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
  }) async {
    try {
      final result = await remoteDataSource.analyzeResume(
        resumeFile: resumeFile,
        jdText: jdText,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> compareMultiple({
    required List<PlatformFile> files,
    required String jdText,
  }) async {
    try {
      final result = await remoteDataSource.compareMultiple(
        files: files,
        jdText: jdText,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getJobMatches({
    required PlatformFile resumeFile,
  }) async {
    try {
      final result = await remoteDataSource.getJobMatches(
        resumeFile: resumeFile,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMarketInsights() async {
    try {
      final result = await remoteDataSource.getMarketInsights();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
