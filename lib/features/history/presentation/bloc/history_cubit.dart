import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/history_usecases.dart';
import '../../../../services/history_service.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryItem> history;
  const HistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class HistoryCubit extends Cubit<HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final SaveHistoryUseCase saveHistoryUseCase;

  HistoryCubit({
    required this.getHistoryUseCase,
    required this.saveHistoryUseCase,
  }) : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final result = await getHistoryUseCase();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (history) => emit(HistoryLoaded(history)),
    );
  }

  Future<void> saveAnalysisResult({
    required String fileName,
    required int score,
    required int percentile,
    required List<String> missingKeywords,
    required List<String> suggestions,
    String? rawJson,
  }) async {
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      score: score,
      date: DateTime.now(),
      missingKeywords: missingKeywords,
      suggestions: suggestions,
      percentile: percentile,
      fullResultJson: rawJson,
    );
    final result = await saveHistoryUseCase(item);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => loadHistory(),
    );
  }

  Future<void> clearHistory() async {
    await HistoryService.clearAll();
    loadHistory();
  }

  Future<void> deleteItem(String id) async {
    await HistoryService.deleteHistory(id);
    loadHistory();
  }
}
