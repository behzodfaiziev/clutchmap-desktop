import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {}

class DarkModeToggled extends SettingsEvent {
  final bool value;
  const DarkModeToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class DevModeToggled extends SettingsEvent {
  final bool value;
  const DevModeToggled(this.value);

  @override
  List<Object?> get props => [value];
}



