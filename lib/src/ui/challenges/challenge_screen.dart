import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ch_app/src/models/challenge.dart';
import './challenge_details.dart';
import 'package:ch_app/src/blocs/challenge.dart';

class ChallengeScreen extends StatefulWidget {
  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    final challengeBloc = BlocProvider.of<ChallengeBloc>(context);

    return Stack(children: <Widget>[
      Image.asset(
        "assets/gideon.jpg",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "DAILY CHALLENGE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(child: BlocBuilder<ChallengeBloc, ChallengeState>(
            builder: (context, state) {
          if (state is ChallengeEmpty) {
            challengeBloc.add(FetchChallengesEvent());
            return SizedBox.shrink();
          } else if (state is ChallengeLoading) {
            return CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor);
          } else if (state is ChallengeError) {
            return Text("Something Wrong Happened");
          } else if (state is ChallengeLoaded) {
            return _buildChallengeList(state.challenges, challengeBloc);
          }
          return null;
        })),
      )
    ]);
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
                elevation: 3,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new ListTile(
                    leading: icon,
                    subtitle: Text.rich(
                        TextSpan(
                          text: challenge.getActiveDateString(),
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15.0)),
                    title: Text.rich(
                        TextSpan(
                          text: challenge.scripture.reference['ar'],
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0)),
                    trailing: SizedBox(width: 30),
                  ),
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
        if (index < challenges.length) {
          return _buildChallengeCard(challenges[index], challengeBloc);
        } else {
          return null;
        }
      },
    );
  }
}
