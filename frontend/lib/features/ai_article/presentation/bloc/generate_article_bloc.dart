import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/ai_article/domain/usecases/generate_article_usecase.dart';
import 'generate_article_event.dart';
import 'generate_article_state.dart';

class GenerateArticleBloc extends Bloc<GenerateArticleEvent, GenerateArticleState> {
  final GenerateArticleUseCase _generateArticleUseCase;

  GenerateArticleBloc(this._generateArticleUseCase) : super(const GenerateArticleInitial()) {
    on<GenerateArticleRequested>(_onGenerateArticleRequested);
  }

  Future<void> _onGenerateArticleRequested(
    GenerateArticleRequested event,
    Emitter<GenerateArticleState> emit,
  ) async {
    emit(const GenerateArticleLoading());
    final result = await _generateArticleUseCase.call(params: event.idea);
    if (result is DataSuccess) {
      emit(GenerateArticleSuccess(result.data!));
    } else {
      emit(GenerateArticleError(result.error?.message ?? 'Failed to generate article'));
    }
  }
}
