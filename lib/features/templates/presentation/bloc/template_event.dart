import 'package:equatable/equatable.dart';

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
  const TemplateSelected(this.templateId);

  @override
  List<Object?> get props => [templateId];
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


