import 'dart:io';

import 'package:ch_app/src/models/challenge.dart';
import 'services.dart';

class ChallengeRepository {
  Future<List<Challenge>> getAllChallenges() async {
    List<Challenge> challengeList =
        await ChallengeNetworkService.fetchChallenges();
    return challengeList;
  }

  Future<Response> postAnswer(int challengeId, int answerId) async {
    Response response =
        await ResponseNetworkService.submitResponse(challengeId, answerId);
    return response;
  }
}
