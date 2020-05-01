import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/score.dart';
import './challenge_details.dart';
import 'package:ch_app/src/blocs/blocs.dart';

class ChallengeScreen extends StatefulWidget {
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _viewRewardBoard = false;

  @override
  Widget build(BuildContext context) {
    final challengeBloc = BlocProvider.of<ChallengeBloc>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "DAILY CHALLENGE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(_viewRewardBoard ? Icons.assignment : Icons.stars,
                  size: 30),
              onPressed: () {
                _toggleView();
              },
            )
          ]),
      body: Center(child:
          BlocBuilder<ChallengeBloc, ChallengeState>(builder: (context, state) {
        if (state is ChallengeEmpty) {
          challengeBloc.add(FetchChallengesEvent());
          return SizedBox.shrink();
        } else if (state is ChallengeLoading) {
          return CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor);
        } else if (state is ChallengeError) {
          return Text("Something Wrong Happened");
        } else if (state is ChallengeLoaded) {
          final List<Challenge> challenges = state.challenges;
          final List<Reward> rewards = challenges
              .map((challenge) =>
                  challenge.isAnsweredCorrectly() ? challenge.reward : null)
              .toList();
          return _viewRewardBoard
              ? _buildRewardBoard(rewards, state.score)
              : _buildChallengeList(challenges, challengeBloc);
        }
        return null;
      })),
    );
  }

  void _toggleView() {
    setState(() {
      _viewRewardBoard = !_viewRewardBoard;
    });
  }

  Widget _buildChallengeCard(Challenge challenge, challengeBloc) {
    Color cardColor = null;
    Icon icon = null;

    if (challenge.isRevealed()) {
      if (challenge.isAnsweredCorrectly()) {
        icon = Icon(
          Icons.star,
          size: 30.0,
          color: challenge.reward.color,
        );
      } else {
        icon = Icon(
          Icons.lock_outline,
          size: 30.0,
          color: Theme.of(context).primaryColor.withAlpha(150),
        );
      }
    } else {
      if (challenge.isAnswered()) {
        cardColor =
            Theme.of(context).primaryColor.withAlpha(150); //Colors.green[900];
        icon = Icon(
          Icons.access_alarm,
          size: 30.0,
          // color: Theme.of(context).primaryColor.withAlpha(150),
        );
      } else {
        cardColor = Theme.of(context).primaryColor;
        icon = Icon(
          Icons.lock_outline,
          size: 30.0,
          // color: Theme.of(context).primaryColor.withAlpha(150),
        );
      }
    }

    return Hero(
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          return SingleChildScrollView(
            child: fromHeroContext.widget,
          );
        },
        tag: "ScriptureTag-${challenge.id}",
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChallengeDetails(
                      challenge: challenge,
                      cardColor: cardColor,
                      answerCallback: (answerId) {
                        Navigator.pop(context);
                        challengeBloc.add(SubmitResponseEvent(
                            challengeId: challenge.id, answerId: answerId));
                      }),
                ),
              );
            },
            child: Card(
                elevation: 5, //challenge.isAnswered() ? 20 : 1,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: new ListTile(
                      title: Text.rich(
                          TextSpan(
                            text: challenge.getActiveDateString(),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17.0)),
                      trailing: icon),
                ))));
  }

  Widget _buildChallengeList(List<Challenge> challenges, challengeBloc) {
    if (challenges.length == 0) {
      return Text.rich(
          TextSpan(
            text: "No Challenges Available",
          ),
          textAlign: TextAlign.center);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(5.0),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return index < challenges.length
            ? _buildChallengeCard(challenges[index], challengeBloc)
            : null;
      },
    );
  }

  Widget _buildRewardCard(Reward reward) {
    if (reward != null) {
      Color color = reward.color;
      bool isBrightColor =
          (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255 >
              0.5;
      Color textColor = isBrightColor ? Colors.black : Colors.white;
      return Card(
          elevation: 5,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Icon(
              //   Icons.star,
              //   size: 30.0,
              //   color: textColor,
              // ),
              reward.score == 0
                  ? Icon(
                      Icons.star,
                      size: 30.0,
                      color: textColor,
                    )
                  : Text.rich(
                      TextSpan(
                          text: NumberFormat.compact().format(reward
                              .score)), // "${reward.score}"), //getColorNameFromColor(color).getName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold),
                    ),
              Text.rich(
                TextSpan(
                    text: reward.name), //getColorNameFromColor(color).getName),
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              )
            ],
          ));
    } else {
      return Card(
          child: Icon(Icons.lock_outline,
              size: 40.0,
              color: Theme.of(context).primaryColor.withAlpha(150)));
    }
  }

  Widget _scoreView(String title, int count, int totalCount, int score) {
    final String formatedScore = NumberFormat().format(score);
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text.rich(
            TextSpan(text: title), //getColorNameFromColor(color).getName),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text.rich(
            TextSpan(
                text:
                    "$count/$totalCount"), //getColorNameFromColor(color).getName),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          Text.rich(
            TextSpan(
                text: formatedScore), //getColorNameFromColor(color).getName),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ]);
  }

  Widget _buildRewardBoard(List<Reward> rewards, Score score) {
    return Column(
      children: <Widget>[
        new Expanded(
            flex: 1,
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                crossAxisCount: 3,
                children: [
                  _scoreView(
                      "30 Days",
                      score.totalCorrectLast30Days,
                      score.totalChallengesLast30Days,
                      score.totalScoreLast30Days),
                  Icon(
                    Icons.star,
                    size: 30.0,
                  ),
                  _scoreView("All Time", score.totalCorrect,
                      score.totalChallenges, score.totalScore),
                ])),
        Divider(
          color: Theme.of(context).primaryColor,
          indent: 10.0,
          endIndent: 10.0,
          thickness: 1.0,
          height: 0,
          // thickness: 10.0,
        ),
        new Expanded(
            flex: 3,
            child: GridView.count(
              primary: false,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              crossAxisCount: 3,
              children:
                  rewards.map((reward) => _buildRewardCard(reward)).toList(),
            )),
        Divider(
          color: Theme.of(context).primaryColor,
          indent: 10.0,
          endIndent: 10.0,
          thickness: 1.0,
          height: 0.0,
        ),
        Divider(height: 20.0, thickness: 0.0, color: Color.fromARGB(0, 0, 0, 0))
      ],
    );
  }
}
