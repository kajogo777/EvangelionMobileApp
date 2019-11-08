import 'package:flutter/material.dart';
import '../models/challenge.dart';

typedef AnswerCallback = Function(int answerId);

class ChallengeDetails extends StatelessWidget {
  final Challenge challenge;
  final Color cardColor;
  final AnswerCallback answerCallback;

  ChallengeDetails(
      {Key key,
      @required this.challenge,
      @required this.cardColor,
      @required this.answerCallback})
      : super(key: key);

  Widget _buildAnswerCard(answer, context) {
    Color cardColor = null;
    Icon cardIcon = null;

    if (challenge.isRevealed()) {
      if (answer.correct) {
        cardColor = Theme.of(context).primaryColor;
        cardIcon = Icon(Icons.done, color: Colors.white, size: 30.0);
      } else {
        cardColor = Colors.redAccent;
        cardIcon = Icon(Icons.clear, color: Colors.white, size: 30.0);
      }
    } else {
      if (challenge.isAnswered()) {
        cardColor = null;
        if (challenge.response.answerId == answer.id) {
          cardIcon = Icon(Icons.access_alarm, color: Colors.white, size: 30.0);
        }
      } else {
        cardColor = null;
      }
    }
    return Card(
      color: cardColor,
      child: ListTile(
        trailing: cardIcon,
        onTap: () {
          print("tapped ${answer.text}");
          answerCallback(answer.id);
        },
        enabled: !challenge.isAnswered() && !challenge.isRevealed(),
        title: Text.rich(
            TextSpan(
              text: answer.text,
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
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
        child: Card(
            color: cardColor,
            child: Center(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(20.0),
                    children: <Widget>[
                  Divider(color: Theme.of(context).accentColor),
                  Text.rich(
                      TextSpan(
                        text: challenge.scripture.getText() + "\n",
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.0)),
                  Text.rich(
                      TextSpan(
                        text: challenge.scripture.reference,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.0)),
                  Divider(color: Theme.of(context).accentColor),
                  Text.rich(
                    TextSpan(
                      text: challenge.question,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Divider(color: Theme.of(context).accentColor),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: challenge.answers
                          .map((answer) => _buildAnswerCard(answer, context))
                          .toList()),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: challenge.isAnswered() && !challenge.isRevealed()
                          ? Text.rich(
                              TextSpan(
                                text:
                                    '"Correct answer will be revealed tomorrow!"',
                              ),
                              textAlign: TextAlign.center,
                            )
                          : null),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: <Widget>[
                                    Icon(isIOS
                                        ? Icons.arrow_back_ios
                                        : Icons.arrow_back),
                                    Text(
                                      "Back",
                                    )
                                  ],
                                ))
                          ])
                    ],
                  ),
                ]))));
  }
}
