import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../infrastructure/datasources/comparison_remote_data_source.dart';
import '../../../matches/infrastructure/datasources/matches_remote_data_source.dart';
import '../../../workspace/infrastructure/datasources/workspace_remote_data_source.dart';
import '../../domain/entities/match_intelligence_summary.dart';
import '../bloc/comparison_event.dart';
import '../bloc/comparison_state.dart';

class ComparisonBloc extends Bloc<ComparisonEvent, ComparisonState> {
  final ComparisonRemoteDataSource comparisonDataSource;
  final MatchesRemoteDataSource matchesDataSource;
  final WorkspaceRemoteDataSource workspaceDataSource;

  ComparisonBloc({
    required this.comparisonDataSource,
    required this.matchesDataSource,
    required this.workspaceDataSource,
  }) : super(ComparisonInitial()) {
    on<MatchesListLoaded>(_onMatchesListLoaded);
    on<MatchASelected>(_onMatchASelected);
    on<MatchBSelected>(_onMatchBSelected);
    on<ComparisonRequested>(_onComparisonRequested);
  }

  Future<void> _onMatchesListLoaded(
    MatchesListLoaded event,
    Emitter<ComparisonState> emit,
  ) async {
    try {
      emit(ComparisonLoading());
      final matches = await matchesDataSource.getMatches();
      emit(ComparisonLoaded(matches: matches));
    } catch (e) {
      emit(ComparisonError(messageFromException(e, fallback: 'Failed to load matches')));
    }
  }

  Future<void> _onMatchASelected(
    MatchASelected event,
    Emitter<ComparisonState> emit,
  ) async {
    if (state is ComparisonLoaded) {
      final currentState = state as ComparisonLoaded;
      final intelligence = await _loadIntelligence(event.matchId);
      emit(currentState.copyWith(
        matchAId: event.matchId,
        intelligenceA: intelligence,
      ));
    }
  }

  Future<void> _onMatchBSelected(
    MatchBSelected event,
    Emitter<ComparisonState> emit,
  ) async {
    if (state is ComparisonLoaded) {
      final currentState = state as ComparisonLoaded;
      final intelligence = await _loadIntelligence(event.matchId);
      emit(currentState.copyWith(
        matchBId: event.matchId,
        intelligenceB: intelligence,
      ));
    }
  }

  Future<void> _onComparisonRequested(
    ComparisonRequested event,
    Emitter<ComparisonState> emit,
  ) async {
    if (state is ComparisonLoaded) {
      final currentState = state as ComparisonLoaded;
      if (currentState.matchAId != null && currentState.matchBId != null) {
        try {
          emit(ComparisonLoading());
          final result = await comparisonDataSource.compareMatches(
            currentState.matchAId!,
            currentState.matchBId!,
          );
          emit(currentState.copyWith(comparisonResult: result));
        } catch (e) {
          emit(ComparisonError(messageFromException(e, fallback: 'Failed to compare matches')));
        }
      }
    }
  }

  Future<MatchIntelligenceSummary?> _loadIntelligence(String matchId) async {
    try {
      final intelligence = await workspaceDataSource.getMatchIntelligence(matchId);
      if (intelligence.isNotEmpty) {
        return MatchIntelligenceSummary(
          aggression: intelligence['aggression'] as int? ?? 0,
          structure: intelligence['structure'] as int? ?? 0,
          variety: intelligence['variety'] as int? ?? 0,
          overall: intelligence['overall'] as int? ?? 0,
          risk: intelligence['risk'] as int? ?? 0,
          volatility: intelligence['volatility'] as int? ?? 0,
        );
      }
    } catch (e) {
      // Ignore errors
    }
    return null;
  }
}

