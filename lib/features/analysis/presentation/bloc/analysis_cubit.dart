import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/analyze_resume_usecase.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();
  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisSuccess extends AnalysisState {
  final AnalysisResult result;
  const AnalysisSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
  @override
  List<Object?> get props => [message];
}

class AnalysisCubit extends Cubit<AnalysisState> {
  final AnalyzeResumeUseCase analyzeResumeUseCase;

  AnalysisCubit({required this.analyzeResumeUseCase})
    : super(AnalysisInitial());

  Future<void> analyzeResume({
    required PlatformFile resumeFile,
    required String jdText,
  }) async {
    emit(AnalysisLoading());
    final result = await analyzeResumeUseCase(
      AnalyzeResumeParams(resumeFile: resumeFile, jdText: jdText),
    );
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (analysisResult) => emit(AnalysisSuccess(analysisResult)),
    );
  }

  void reset() => emit(AnalysisInitial());
}
