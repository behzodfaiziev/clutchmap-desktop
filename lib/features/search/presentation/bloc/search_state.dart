import 'package:equatable/equatable.dart';
import '../../domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadedState extends SearchState {
  final List<SearchResult> results;
  final String query;
  final int selectedIndex;

  const SearchLoadedState({
    required this.results,
    required this.query,
    this.selectedIndex = 0,
  });

  SearchLoadedState copyWith({
    List<SearchResult>? results,
    String? query,
    int? selectedIndex,
  }) {
    return SearchLoadedState(
      results: results ?? this.results,
      query: query ?? this.query,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [results, query, selectedIndex];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}



