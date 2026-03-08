import 'package:equatable/equatable.dart';
import '../../domain/entities/strategy_template.dart';
import '../../domain/entities/template_detail.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {}

class TemplateLoading extends TemplateState {}

class TemplateLoadedState extends TemplateState {
  final List<StrategyTemplate> templates;
  final TemplateDetail? selectedTemplate;
  final String? createdMatchId;

  const TemplateLoadedState({
    required this.templates,
    this.selectedTemplate,
    this.createdMatchId,
  });

  TemplateLoadedState copyWith({
    List<StrategyTemplate>? templates,
    TemplateDetail? selectedTemplate,
    String? createdMatchId,
  }) {
    return TemplateLoadedState(
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      createdMatchId: createdMatchId ?? this.createdMatchId,
    );
  }

  @override
  List<Object?> get props => [templates, selectedTemplate, createdMatchId];
}

class TemplateError extends TemplateState {
  final String message;

  const TemplateError(this.message);

  @override
  List<Object?> get props => [message];
}

