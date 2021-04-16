import 'package:flutter/material.dart';

class Score {
  final int totalChallenges;
  final int totalAttempted;
  final int totalCorrect;
  final int totalScore;
  final int totalChallengesLast30Days;
  final int totalAttemptedLast30Days;
  final int totalCorrectLast30Days;
  final int totalScoreLast30Days;

  Score({
    this.totalChallenges,
    this.totalAttempted,
    this.totalCorrect,
    this.totalScore,
    this.totalChallengesLast30Days,
    this.totalAttemptedLast30Days,
    this.totalCorrectLast30Days,
    this.totalScoreLast30Days,
  });

  Score.fromJson(Map<String, dynamic> data)
      : totalChallenges = data['total_challenges'],
        totalAttempted = data['total_attempted'],
        totalCorrect = data['total_correct'],
        totalScore = data['total_score'],
        totalChallengesLast30Days = data['total_challenges_last_30_days'],
        totalAttemptedLast30Days = data['total_attempted_last_30_days'],
        totalCorrectLast30Days = data['total_correct_last_30_days'],
        totalScoreLast30Days = data['total_score_last_30_days'];
}
