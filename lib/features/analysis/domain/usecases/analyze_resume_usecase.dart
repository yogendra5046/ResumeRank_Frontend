import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/analysis_result.dart';
import '../repositories/analysis_repository.dart';

class AnalyzeResumeUseCase {
  final AnalysisRepository repository;

  AnalyzeResumeUseCase(this.repository);

  Future<Either<Failure, AnalysisResult>> call(
    AnalyzeResumeParams params,
  ) async {
    return await repository.analyzeResume(
      resumeFile: params.resumeFile,
      jdText: params.jdText,
    );
  }
}

class AnalyzeResumeParams extends Equatable {
  final PlatformFile resumeFile;
  final String jdText;

  const AnalyzeResumeParams({required this.resumeFile, required this.jdText});

  @override
  List<Object?> get props => [resumeFile, jdText];
}
