import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/score.dart';
import 'package:ch_app/src/data/repositories.dart';

// EVENTS
abstract class ChallengeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchChallengesEvent extends ChallengeEvent {}

class SubmitResponseEvent extends ChallengeEvent {
  final int challengeId;
  final int answerId;

  SubmitResponseEvent({@required this.challengeId, @required this.answerId})
      : assert(challengeId != null),
        assert(answerId != null);

  @override
  List<Object> get props => super.props..addAll([challengeId, answerId]);
}

// STATES
abstract class ChallengeState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChallengeEmpty extends ChallengeState {}

class ChallengeLoading extends ChallengeState {}

class ChallengeLoaded extends ChallengeState {
  final List<Challenge> challenges;

  ChallengeLoaded({@required this.challenges}) : assert(challenges != null);

  @override
  List<Object> get props => super.props..addAll([challenges]);
}

class ChallengeError extends ChallengeState {}

//BLOCS
class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final ChallengeRepository challengeRepository;

  ChallengeBloc({@required this.challengeRepository})
      : assert(challengeRepository != null);

  @override
  ChallengeState get initialState => ChallengeEmpty();

  @override
  Stream<ChallengeState> mapEventToState(ChallengeEvent event) async* {
    final currentState = state;

    List<Challenge> currentChallenges = [];

    if (currentState is ChallengeLoaded) {
      currentChallenges = currentState.challenges;
    }

    yield ChallengeLoading();

    if (event is FetchChallengesEvent) {
      final List<Challenge> challenges =
          await challengeRepository.getChallenges(20, 0);
      yield ChallengeLoaded(challenges: challenges);
    } else if (event is SubmitResponseEvent) {
      final Response response = await challengeRepository.postAnswer(
          event.challengeId, event.answerId);
      final List<Challenge> challenges = currentChallenges.map((challenge) {
        if (response.challengeId == challenge.id) {
          return challenge.copyWith(response);
        } else {
          return challenge.copyWith(null);
        }
      }).toList();
      yield ChallengeLoaded(challenges: challenges);
    }
  }
}
