import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/analysis_result.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, AnalysisResult>> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
  });

  Future<Either<Failure, Map<String, dynamic>>> compareMultiple({
    required List<PlatformFile> files,
    required String jdText,
  });

  Future<Either<Failure, Map<String, dynamic>>> getJobMatches({
    required PlatformFile resumeFile,
  });

  Future<Either<Failure, Map<String, dynamic>>> getMarketInsights();
}
