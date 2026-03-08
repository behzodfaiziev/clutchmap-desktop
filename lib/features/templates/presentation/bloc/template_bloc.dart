import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/strategy_template.dart';
import '../../domain/entities/template_detail.dart';
import '../../infrastructure/datasources/template_remote_data_source.dart';
import 'template_event.dart';
import 'template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRemoteDataSource dataSource;

  TemplateBloc({required this.dataSource}) : super(TemplateInitial()) {
    on<TemplatesLoaded>(_onTemplatesLoaded);
    on<TemplateSelected>(_onTemplateSelected);
    on<CreateTemplate>(_onCreateTemplate);
    on<ApplyTemplate>(_onApplyTemplate);
  }

  Future<void> _onTemplatesLoaded(
    TemplatesLoaded event,
    Emitter<TemplateState> emit,
  ) async {
    emit(TemplateLoading());
    try {
      final templatesData = await dataSource.getTemplates();
      final templates = templatesData
          .map((json) => StrategyTemplate.fromJson(json))
          .toList();

      emit(TemplateLoadedState(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onTemplateSelected(
    TemplateSelected event,
    Emitter<TemplateState> emit,
  ) async {
    if (state is TemplateLoadedState) {
      final currentState = state as TemplateLoadedState;
      emit(TemplateLoading());
      try {
        final templateData = await dataSource.getTemplate(event.templateId);
        final template = StrategyTemplate.fromJson(templateData);
        // For now, use placeholder values for detail
        final detail = TemplateDetail(
          template: template,
          roundsCount: 0, // Would come from backend
          aggressionScore: null,
          structureScore: null,
        );
        emit(currentState.copyWith(selectedTemplate: detail));
      } catch (e) {
        emit(TemplateError(e.toString()));
      }
    }
  }

  Future<void> _onCreateTemplate(
    CreateTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(TemplateLoading());
    try {
      await dataSource.createTemplateFromMatch(event.templateName, event.matchId);
      // Reload templates after creation
      final templatesData = await dataSource.getTemplates();
      final templates = templatesData
          .map((json) => StrategyTemplate.fromJson(json))
          .toList();
      emit(TemplateLoadedState(templates: templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onApplyTemplate(
    ApplyTemplate event,
    Emitter<TemplateState> emit,
  ) async {
    emit(TemplateLoading());
    try {
      final matchData = await dataSource.applyTemplate(
        event.templateId,
        event.title,
        event.folderId,
      );
      // Extract match ID from response
      final matchId = matchData['id'] as String?;
      if (state is TemplateLoadedState) {
        final currentState = state as TemplateLoadedState;
        emit(currentState.copyWith(createdMatchId: matchId));
      } else {
        emit(TemplateLoadedState(templates: [], createdMatchId: matchId));
      }
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }
}

