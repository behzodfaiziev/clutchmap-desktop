import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_result.dart';
import '../../infrastructure/datasources/search_remote_data_source.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRemoteDataSource dataSource;
  Timer? _debounceTimer;

  SearchBloc({required this.dataSource}) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchResultSelected>(_onSearchResultSelected);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    // Debounce search queries
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      emit(SearchLoading());
      try {
        final resultsData = await dataSource.search(event.query);
        final results = resultsData
            .map((json) => SearchResult.fromJson(json))
            .toList();

        emit(SearchLoadedState(
          results: results,
          query: event.query,
          selectedIndex: 0,
        ));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    });
  }

  void _onSearchResultSelected(
    SearchResultSelected event,
    Emitter<SearchState> emit,
  ) {
    // Navigation is handled by the overlay widget
    // This event is mainly for tracking
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}



