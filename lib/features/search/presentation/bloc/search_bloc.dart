import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../../../core/team/active_team_service.dart';
import '../../domain/entities/search_result.dart';
import '../../infrastructure/datasources/search_remote_data_source.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRemoteDataSource dataSource;
  final ActiveTeamService activeTeamService;
  Timer? _debounceTimer;

  SearchBloc({required this.dataSource, required this.activeTeamService}) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchResultSelected>(_onSearchResultSelected);
    on<SearchSelectionMoved>(_onSearchSelectionMoved);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();

    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(SearchLoading());
      try {
        final teamId = activeTeamService.activeTeamId;
        final gameType = event.gameType ?? 'VALORANT';

        if (teamId != null && teamId.isNotEmpty) {
          final resultsData = await dataSource.hybridSearch(
            teamId: teamId,
            gameType: gameType,
            query: event.query.trim(),
            mapCode: event.mapCode,
            pattern: event.pattern,
            scope: event.scope,
          );
          final results = resultsData
              .map((json) => SearchResult.fromHybridJson(json))
              .toList();
          emit(SearchLoadedState(
            results: results,
            query: event.query,
            selectedIndex: 0,
          ));
        } else {
          final resultsData = await dataSource.search(event.query.trim());
          final results = resultsData
              .map((json) => SearchResult.fromJson(json))
              .toList();
          emit(SearchLoadedState(
            results: results,
            query: event.query,
            selectedIndex: 0,
          ));
        }
      } catch (e) {
        emit(SearchError(messageFromException(e, fallback: 'Search failed')));
      }
    });
  }

  void _onSearchResultSelected(
    SearchResultSelected event,
    Emitter<SearchState> emit,
  ) {
    // Navigation is handled by the overlay widget
  }

  void _onSearchSelectionMoved(
    SearchSelectionMoved event,
    Emitter<SearchState> emit,
  ) {
    if (state is! SearchLoadedState) return;
    final current = state as SearchLoadedState;
    if (current.results.isEmpty) return;
    final next = (current.selectedIndex + event.delta).clamp(0, current.results.length - 1);
    if (next != current.selectedIndex) {
      emit(current.copyWith(selectedIndex: next));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}



