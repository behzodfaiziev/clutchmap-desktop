import 'package:equatable/equatable.dart';
import '../../domain/entities/strategy_template.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class TemplatesLoaded extends TemplateEvent {
  const TemplatesLoaded();
}

class TemplateSelected extends TemplateEvent {
  final String templateId;
  /// When set, detail is built from list data (avoids GET /templates/{id} when backend has no single-template endpoint).
  final StrategyTemplate? templateFromList;
  const TemplateSelected(this.templateId, {this.templateFromList});

  @override
  List<Object?> get props => [templateId, templateFromList];
}

class CreateTemplate extends TemplateEvent {
  final String matchId;
  final String templateName;
  const CreateTemplate(this.matchId, this.templateName);

  @override
  List<Object?> get props => [matchId, templateName];
}

class ApplyTemplate extends TemplateEvent {
  final String templateId;
  final String title;
  final String? folderId;
  const ApplyTemplate(this.templateId, this.title, {this.folderId});

  @override
  List<Object?> get props => [templateId, title, folderId];
}

class TemplateSelectionCleared extends TemplateEvent {
  const TemplateSelectionCleared();
}


