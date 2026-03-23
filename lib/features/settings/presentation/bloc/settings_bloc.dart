import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../domain/entities/app_settings.dart';
import '../../infrastructure/datasources/settings_local_data_source.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsLocalDataSource localDataSource;

  SettingsBloc({required this.localDataSource})
      : super(SettingsState(
          settings: const AppSettings(darkMode: true, devMode: false),
        )) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<DarkModeToggled>(_onDarkModeToggled);
    on<DevModeToggled>(_onDevModeToggled);
  }

  Future<void> _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await localDataSource.loadSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: messageFromException(e, fallback: 'Failed to load settings'), isLoading: false));
    }
  }

  Future<void> _onDarkModeToggled(
    DarkModeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final updatedSettings = state.settings.copyWith(darkMode: event.value);
    emit(state.copyWith(settings: updatedSettings));
    try {
      await localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      // Revert on error
      emit(state.copyWith(settings: state.settings));
    }
  }

  Future<void> _onDevModeToggled(
    DevModeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final updatedSettings = state.settings.copyWith(devMode: event.value);
    emit(state.copyWith(settings: updatedSettings));
    try {
      await localDataSource.saveSettings(updatedSettings);
    } catch (e) {
      // Revert on error
      emit(state.copyWith(settings: state.settings));
    }
  }
}



