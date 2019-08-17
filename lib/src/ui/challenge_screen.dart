import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/challenge.dart';
import '../ui/challenge_details.dart';
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
          challengeBloc.dispatch(FetchChallengesEvent());
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
              ? _buildRewardBoard(rewards)
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
                        challengeBloc.dispatch(SubmitResponseEvent(
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
              Icon(
                Icons.star,
                size: 30.0,
                color: textColor,
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

  Widget _buildRewardBoard(List<Reward> rewards) {
    final int starCount = rewards.fold(0, (count, reward) {
      return reward != null ? count + 1 : count;
    });
    return Column(
      children: <Widget>[
        new ListTile(
            leading: Icon(
              Icons.star,
              size: 30.0,
            ),
            title: Text.rich(
              TextSpan(
                  text: "Token Count"), //getColorNameFromColor(color).getName),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            trailing: Text.rich(
              TextSpan(
                  text:
                      "$starCount/${rewards.length}"), //getColorNameFromColor(color).getName),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            )),
        new Expanded(
            child: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(10.0),
          crossAxisSpacing: 5.0,
          crossAxisCount: 3,
          children: rewards.map((reward) => _buildRewardCard(reward)).toList(),
        ))
      ],
    );
    // return GridView.count(
    //   primary: false,
    //   padding: const EdgeInsets.all(20.0),
    //   crossAxisSpacing: 10.0,
    //   crossAxisCount: 3,
    //   children: rewards.map((reward) => _buildRewardCard(reward)).toList(),
    // );
  }
}
