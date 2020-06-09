import 'dart:io';

import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/score.dart';
import 'package:ch_app/src/models/post.dart';
import 'services.dart';

class ChallengeRepository {
  Future<List<Challenge>> getAllChallenges() async {
    List<Challenge> challengeList =
        await ChallengeNetworkService.fetchChallenges();
    return challengeList;
  }

  Future<List<Challenge>> getChallenges(int limit, int offset) async {
    List<Challenge> challengeList =
        await ChallengeNetworkService.fetchChallenges(
            limit = limit, offset = offset);
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

class PostRepository {
  Future<List<ConcisePost>> getPosts(int limit, int offset) async {
    List<ConcisePost> items =
        await PostNetworkService.fetchPosts(limit = limit, offset = offset);
    return items;
  }

  Future<Post> fetchPost(int postId) async {
    return await PostNetworkService.fetchPost(postId);
  }
}
