import 'dart:io';

import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/score.dart';
import 'services.dart';

class ChallengeRepository {
  Future<List<Challenge>> getAllChallenges() async {
    List<Challenge> challengeList =
        await ChallengeNetworkService.fetchChallenges();
    return challengeList;
  }

  Future<List<Challenge>> getChallenges(int limit, int offset) async {
    List<Challenge> challengeList =
        await ChallengeNetworkService.fetchChallenges(limit=limit, offset=offset);
    return challengeList;
  }

  Future<Response> postAnswer(int challengeId, int answerId) async {
    Response response =
        await ResponseNetworkService.submitResponse(challengeId, answerId);
    return response;
  }

  Future<Score> fetchScore() async {
    return await ScoreNetworkService.fetchScore();
  }
}
