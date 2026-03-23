import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../../opponents/infrastructure/datasources/opponent_remote_data_source.dart';
import '../../infrastructure/datasources/matches_remote_data_source.dart';
import 'matches_event.dart';
import 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final MatchesRemoteDataSource dataSource;
  final OpponentRemoteDataSource opponentDataSource;

  MatchesBloc({required this.dataSource, required this.opponentDataSource}) : super(MatchesLoading()) {
    on<MatchesLoaded>(_onMatchesLoaded);
    on<MatchCreated>(_onMatchCreated);
    on<ClearCreatedMatchId>(_onClearCreatedMatchId);
    on<MatchArchived>(_onMatchArchived);
    on<MatchRestored>(_onMatchRestored);
    on<MatchDeleted>(_onMatchDeleted);
    on<MatchDuplicated>(_onMatchDuplicated);
  }

  Future<void> _onMatchesLoaded(
    MatchesLoaded event,
    Emitter<MatchesState> emit,
  ) async {
    emit(MatchesLoading());

    try {
      final matches = await dataSource.getMatches(
        filter: event.filter,
        q: event.query,
        folderId: event.folderId,
        gameId: event.gameId,
        mapId: event.mapId,
        opponentId: event.opponentId,
      );
      Map<String, String> opponentNamesById = {};
      try {
        final opponents = await opponentDataSource.getOpponents();
        for (final o in opponents) {
          final id = o['id']?.toString();
          final name = o['name'] as String?;
          if (id != null && id.isNotEmpty && name != null) {
            opponentNamesById[id] = name;
          }
        }
      } catch (_) {
        // Non-fatal; list will show opponent id or "Opponent" if missing
      }
      emit(MatchesLoadedState(
        matches.map((m) => m.toEntity()).toList(),
        lastCreatedMatchId: event.createdMatchId,
        lastCreatedWasDuplicate: event.createdWasDuplicate,
        lastQuery: event.query,
        lastFilter: event.filter,
        lastOpponentId: event.opponentId,
        lastFolderId: event.folderId,
        lastGameId: event.gameId,
        lastMapId: event.mapId,
        duplicatingMatchId: null, // Clear when reload completes
        opponentNamesById: opponentNamesById,
      ));
    } catch (e) {
      emit(MatchesError(
        messageFromException(e, fallback: 'Failed to load matches'),
        lastFilter: event.filter,
        lastQuery: event.query,
        lastOpponentId: event.opponentId,
        lastFolderId: event.folderId,
        lastGameId: event.gameId,
        lastMapId: event.mapId,
      ));
    }
  }

  Future<void> _onMatchCreated(
    MatchCreated event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      final created = await dataSource.createMatch(
        title: event.title,
        mapId: event.mapId,
        gameId: event.gameId,
        folderId: event.folderId,
        opponentId: event.opponentId,
        startingSide: event.startingSide,
      );
      add(MatchesLoaded(createdMatchId: created.id));
    } catch (e) {
      emit(MatchesError(messageFromException(e, fallback: 'Failed to create match')));
    }
  }

  void _onClearCreatedMatchId(
    ClearCreatedMatchId event,
    Emitter<MatchesState> emit,
  ) {
    if (state is MatchesLoadedState) {
      final s = state as MatchesLoadedState;
      emit(MatchesLoadedState(s.matches));
    }
  }

  Future<void> _onMatchArchived(
    MatchArchived event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.archiveMatch(event.matchId);
      final s = state;
      add(MatchesLoaded(
        filter: s is MatchesLoadedState ? s.lastFilter : null,
        query: s is MatchesLoadedState ? s.lastQuery : null,
        opponentId: s is MatchesLoadedState ? s.lastOpponentId : null,
        folderId: s is MatchesLoadedState ? s.lastFolderId : null,
        gameId: s is MatchesLoadedState ? s.lastGameId : null,
        mapId: s is MatchesLoadedState ? s.lastMapId : null,
      ));
    } catch (e) {
      emit(MatchesError(messageFromException(e, fallback: 'Failed to archive match')));
    }
  }

  Future<void> _onMatchRestored(
    MatchRestored event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.unarchiveMatch(event.matchId);
      final s = state;
      add(MatchesLoaded(
        filter: s is MatchesLoadedState ? s.lastFilter : null,
        query: s is MatchesLoadedState ? s.lastQuery : null,
        opponentId: s is MatchesLoadedState ? s.lastOpponentId : null,
        folderId: s is MatchesLoadedState ? s.lastFolderId : null,
        gameId: s is MatchesLoadedState ? s.lastGameId : null,
        mapId: s is MatchesLoadedState ? s.lastMapId : null,
      ));
    } catch (e) {
      emit(MatchesError(messageFromException(e, fallback: 'Failed to restore match')));
    }
  }

  Future<void> _onMatchDeleted(
    MatchDeleted event,
    Emitter<MatchesState> emit,
  ) async {
    try {
      await dataSource.deleteMatch(event.matchId);
      final s = state;
      add(MatchesLoaded(
        filter: s is MatchesLoadedState ? s.lastFilter : null,
        query: s is MatchesLoadedState ? s.lastQuery : null,
        opponentId: s is MatchesLoadedState ? s.lastOpponentId : null,
        folderId: s is MatchesLoadedState ? s.lastFolderId : null,
        gameId: s is MatchesLoadedState ? s.lastGameId : null,
        mapId: s is MatchesLoadedState ? s.lastMapId : null,
      ));
    } catch (e) {
      emit(MatchesError(messageFromException(e, fallback: 'Failed to delete match')));
    }
  }

  Future<void> _onMatchDuplicated(
    MatchDuplicated event,
    Emitter<MatchesState> emit,
  ) async {
    if (state is MatchesLoadedState) {
      final currentState = state as MatchesLoadedState;
      emit(currentState.copyWith(duplicatingMatchId: event.matchId));
    }
    try {
      final created = await dataSource.duplicateMatch(event.matchId);
      add(MatchesLoaded(
        createdMatchId: created.id,
        createdWasDuplicate: true,
        filter: state is MatchesLoadedState ? (state as MatchesLoadedState).lastFilter : null,
        query: state is MatchesLoadedState ? (state as MatchesLoadedState).lastQuery : null,
        opponentId: state is MatchesLoadedState ? (state as MatchesLoadedState).lastOpponentId : null,
      ));
    } catch (e) {
      if (state is MatchesLoadedState) {
        final currentState = state as MatchesLoadedState;
        emit(currentState.copyWith(clearDuplicatingMatchId: true));
      }
      emit(MatchesError(messageFromException(e, fallback: 'Failed to duplicate match')));
    }
  }
}



