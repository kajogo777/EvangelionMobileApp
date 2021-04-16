import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ch_app/src/models/score.dart';
import 'package:ch_app/src/models/user.dart';
import 'package:ch_app/src/models/challenge.dart';

import 'package:ch_app/src/data/repositories.dart';

// EVENTS
abstract class ProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

// STATES
abstract class ProfileState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileEmpty extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final Score score;
  final List<Reward> rewards;

  ProfileLoaded(
      {@required this.user, @required this.score, @required this.rewards})
      : assert(user != null),
        assert(score != null),
        assert(rewards != null);

  @override
  List<Object> get props => super.props..addAll([user, score]);
}

class ProfileError extends ProfileState {}

//BLOCS
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final ChallengeRepository challengeRepository;

  ProfileBloc(
      {@required this.profileRepository, @required this.challengeRepository})
      : assert(profileRepository != null),
        assert(challengeRepository != null);

  @override
  ProfileState get initialState => ProfileEmpty();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    yield ProfileLoading();

    if (event is FetchProfileEvent) {
      final Score score = await profileRepository.fetchScore();
      final User user = await profileRepository.fetchUser();
      final List<Reward> rewards =
          (await challengeRepository.getChallenges(20, 0))
              .map((challenge) =>
                  challenge.isAnsweredCorrectly() ? challenge.reward : null)
              .toList();

      yield ProfileLoaded(
        user: user,
        score: score,
        rewards: rewards,
      );
    }
  }
}
