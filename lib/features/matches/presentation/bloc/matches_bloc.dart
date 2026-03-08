import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../infrastructure/datasources/matches_remote_data_source.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesRemoteDataSource dataSource;

  MatchesBloc({required this.dataSource}) : super(MatchesLoading()) {
    on<MatchesLoaded>(_onMatchesLoaded);
    on<MatchCreated>(_onMatchCreated);
    on<MatchArchived>(_onMatchArchived);
    on<MatchRestored>(_onMatchRestored);
    on<MatchDeleted>(_onMatchDeleted);
  }

  Future<void> _onMatchesLoaded(
    MatchesLoaded event,
    Emitter<MatchesState> emit,
  ) async {
    emit(MatchesLoading());

    try {
      final matches = await dataSource.getMatches(filter: event.filter);
      emit(MatchesLoadedState(
        matches.map((m) => m.toEntity()).toList(),
      ));
    } on DioException catch (e) {
      emit(MatchesError(
        e.response?.data?['message'] as String? ?? 'Failed to load matches',
      ));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> _onMatchCreated(
    MatchCreated event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.createMatch(
        title: event.title,
        mapId: event.mapId,
        gameId: event.gameId,
        folderId: event.folderId,
        opponentId: event.opponentId,
        startingSide: event.startingSide,
      );
      // Reload matches
      add(const MatchesLoaded());
    } on DioException catch (e) {
      emit(MatchesError(
        e.response?.data?['message'] as String? ?? 'Failed to create match',
      ));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> _onMatchArchived(
    MatchArchived event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.archiveMatch(event.matchId);
      // Reload matches
      add(const MatchesLoaded());
    } on DioException catch (e) {
      emit(MatchesError(
        e.response?.data?['message'] as String? ?? 'Failed to archive match',
      ));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> _onMatchRestored(
    MatchRestored event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.unarchiveMatch(event.matchId);
      // Reload matches
      add(const MatchesLoaded());
    } on DioException catch (e) {
      emit(MatchesError(
        e.response?.data?['message'] as String? ?? 'Failed to restore match',
      ));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }

  Future<void> _onMatchDeleted(
    MatchDeleted event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.deleteMatch(event.matchId);
      // Reload matches
      add(const MatchesLoaded());
    } on DioException catch (e) {
      emit(MatchesError(
        e.response?.data?['message'] as String? ?? 'Failed to delete match',
      ));
    } catch (e) {
      emit(MatchesError(e.toString()));
    }
  }
}



