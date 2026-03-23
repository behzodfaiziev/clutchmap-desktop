import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../domain/entities/opponent_profile.dart';
import '../../domain/entities/matchup_analysis.dart';
import '../../infrastructure/datasources/opponent_remote_data_source.dart';
import 'opponent_event.dart';
import 'opponent_state.dart';

class OpponentBloc extends Bloc<OpponentEvent, OpponentState> {
  final OpponentRemoteDataSource dataSource;

  OpponentBloc({required this.dataSource}) : super(OpponentLoading()) {
    on<OpponentsLoaded>(_onOpponentsLoaded);
    on<OpponentSelected>(_onOpponentSelected);
    on<OpponentCreated>(_onOpponentCreated);
    on<OpponentUpdated>(_onOpponentUpdated);
    on<OpponentDeleted>(_onOpponentDeleted);
  }

  Future<void> _onOpponentsLoaded(
    OpponentsLoaded event,
    Emitter<OpponentState> emit,
  ) async {
    emit(OpponentLoading());

    try {
      final opponentsData = await dataSource.getOpponents();
      final opponents = opponentsData
          .map((json) => OpponentProfile.fromJson(json))
          .toList();

      emit(OpponentLoadedState(opponents: opponents));
    } catch (e) {
      emit(OpponentError(messageFromException(e, fallback: 'Failed to load opponents')));
    }
  }

  Future<void> _onOpponentSelected(
    OpponentSelected event,
    Emitter<OpponentState> emit,
  ) async {
    if (state is OpponentLoadedState) {
      final currentState = state as OpponentLoadedState;
      emit(currentState.copyWith(selectedOpponent: null, matchup: null));

      try {
        // Load team intelligence to get team profile
        final teamIntelData = await dataSource.getTeamIntelligence(event.teamId);
        final teamProfile = OpponentProfile.fromJson({
          'id': event.teamId,
          'name': 'Your Team',
          'avgAggressionScore': teamIntelData['avgAggressionScore'],
          'avgStructureScore': teamIntelData['avgStructureScore'],
          'avgVarietyScore': teamIntelData['avgVarietyScore'],
          'risk': 0, // Risk not in intelligence view
        });

        // Load matchup data
        final matchupData = await dataSource.getMatchup(event.teamId, event.opponentId);
        final matchup = MatchupAnalysis.fromJson(matchupData);

        // Construct opponent profile from matchup gaps and team profile
        final selectedOpponent = OpponentProfile(
          id: event.opponentId,
          name: currentState.opponents
                  .firstWhere((o) => o.id == event.opponentId, orElse: () => OpponentProfile(
                        id: event.opponentId,
                        name: 'Unknown',
                        aggression: 0,
                        structure: 0,
                        variety: 0,
                        risk: 0,
                      ))
                  .name,
          aggression: teamProfile.aggression - matchup.aggressionGap,
          structure: teamProfile.structure - matchup.structureGap,
          variety: teamProfile.variety - matchup.varietyGap,
          risk: 0, // Risk not available in matchup
        );

        emit(currentState.copyWith(
          selectedOpponent: selectedOpponent,
          teamProfile: teamProfile,
          matchup: matchup,
        ));
      } catch (e) {
        emit(OpponentError(messageFromException(e, fallback: 'Failed to load opponent')));
      }
    }
  }

  Future<void> _onOpponentCreated(
    OpponentCreated event,
    Emitter<OpponentState> emit,
  ) async {
    if (state is OpponentLoadedState) {
      emit(OpponentLoading());
      try {
        await dataSource.createOpponent(
          name: event.name,
          region: event.region,
          notes: event.notes,
          tags: event.tags,
        );
        add(const OpponentsLoaded());
      } catch (e) {
        emit(OpponentError(messageFromException(e, fallback: 'Failed to create opponent')));
      }
    }
  }

  Future<void> _onOpponentUpdated(
    OpponentUpdated event,
    Emitter<OpponentState> emit,
  ) async {
    if (state is OpponentLoadedState) {
      emit(OpponentLoading());
      try {
        await dataSource.updateOpponent(
          event.opponentId,
          name: event.name,
          region: event.region,
          notes: event.notes,
          tags: event.tags,
        );
        add(const OpponentsLoaded());
      } catch (e) {
        emit(OpponentError(messageFromException(e, fallback: 'Failed to update opponent')));
      }
    }
  }

  Future<void> _onOpponentDeleted(
    OpponentDeleted event,
    Emitter<OpponentState> emit,
  ) async {
    if (state is OpponentLoadedState) {
      emit(OpponentLoading());
      try {
        await dataSource.deleteOpponent(event.opponentId);
        add(const OpponentsLoaded());
      } catch (e) {
        emit(OpponentError(messageFromException(e, fallback: 'Failed to delete opponent')));
      }
    }
  }
}



