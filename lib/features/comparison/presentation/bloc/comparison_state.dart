import 'package:equatable/equatable.dart';
import '../../domain/entities/comparison_result.dart';
import '../../domain/entities/match_intelligence_summary.dart';
import '../../../matches/infrastructure/models/match_summary_model.dart';

abstract class ComparisonState extends Equatable {
  const ComparisonState();

  @override
  List<Object?> get props => [];
}

class ComparisonInitial extends ComparisonState {}

class ComparisonLoading extends ComparisonState {}

class ComparisonLoaded extends ComparisonState {
  final List<MatchSummaryModel> matches;
  final String? matchAId;
  final String? matchBId;
  final MatchIntelligenceSummary? intelligenceA;
  final MatchIntelligenceSummary? intelligenceB;
  final ComparisonResult? comparisonResult;

  const ComparisonLoaded({
    required this.matches,
    this.matchAId,
    this.matchBId,
    this.intelligenceA,
    this.intelligenceB,
    this.comparisonResult,
  });

  ComparisonLoaded copyWith({
    List<MatchSummaryModel>? matches,
    String? matchAId,
    String? matchBId,
    MatchIntelligenceSummary? intelligenceA,
    MatchIntelligenceSummary? intelligenceB,
    ComparisonResult? comparisonResult,
  }) {
    return ComparisonLoaded(
      matches: matches ?? this.matches,
      matchAId: matchAId ?? this.matchAId,
      matchBId: matchBId ?? this.matchBId,
      intelligenceA: intelligenceA ?? this.intelligenceA,
      intelligenceB: intelligenceB ?? this.intelligenceB,
      comparisonResult: comparisonResult ?? this.comparisonResult,
    );
  }

  @override
  List<Object?> get props => [
        matches,
        matchAId,
        matchBId,
        intelligenceA,
        intelligenceB,
        comparisonResult,
      ];
}

class ComparisonError extends ComparisonState {
  final String message;

  const ComparisonError(this.message);

  @override
  List<Object?> get props => [message];
}

