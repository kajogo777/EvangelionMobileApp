import 'package:flutter/material.dart';
import 'package:ch_app/src/models/challenge.dart';

typedef AnswerCallback = Function(int answerId);

class Reading extends StatefulWidget {
  final Challenge challenge;
  final String lang;

  Reading({Key key, @required this.challenge, @required this.lang})
      : super(key: key);

  @override
  _ReadingState createState() => _ReadingState();
}

class _ReadingState extends State<Reading> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        FlatButton(
            onPressed: () {
              setState(() {
                _show = !_show;
              });
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
              Text.rich(
                  TextSpan(
                      text: widget.challenge.scripture.reference[widget.lang]),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0))
            ])),
        Visibility(
            visible: _show,
            child: Text.rich(
                TextSpan(
                  text: widget.challenge.scripture.getText(widget.lang),
                ),
                textDirection:
                    widget.lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
                textAlign:
                    widget.lang == "ar" ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 17.0)))
      ],
    );
  }
}

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
    // Widget enContainer = getEnglishContainer(containerWidth);
    // Widget arContainer = getArabicContainer(containerWidth);
    return Hero(
        // flightShuttleBuilder: (
        //   BuildContext flightContext,
        //   Animation<double> animation,
        //   HeroFlightDirection flightDirection,
        //   BuildContext fromHeroContext,
        //   BuildContext toHeroContext,
        // ) {
        //   return SingleChildScrollView(
        //     child: fromHeroContext.widget,
        //   );
        // },
        tag: "ScriptureTag-${challenge.id}",
        child: Card(
            color: cardColor,
            child: Center(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(20.0),
                    children: <Widget>[
                  Divider(color: Theme.of(context).accentColor),
                  // Container(
                  //   height: 500,
                  //   child: ListView(
                  //       shrinkWrap: true,
                  //       scrollDirection: Axis.horizontal,
                  //       children: <Widget>[
                  //         enContainer,
                  //         VerticalDivider(color: Theme.of(context).accentColor),
                  //         arContainer
                  //       ]),
                  // ),
                  Reading(challenge: challenge, lang: "ar"),
                  Divider(color: Theme.of(context).accentColor),
                  Reading(challenge: challenge, lang: "en"),
                  Divider(color: Theme.of(context).accentColor),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text.rich(
                          TextSpan(
                            text: challenge.question,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17.0))),
                  // Divider(color: Theme.of(context).accentColor),
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
