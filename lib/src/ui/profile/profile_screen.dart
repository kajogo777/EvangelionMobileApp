import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ch_app/src/models/challenge.dart';
import 'package:ch_app/src/models/score.dart';
import 'package:ch_app/src/blocs/profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<ProfileBloc>(context);

    return BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
      Widget child;
      String title = "PROFILE";
      if (state is ProfileEmpty) {
        profileBloc.add(FetchProfileEvent());
        child = SizedBox.shrink();
      } else if (state is ProfileLoading) {
        child = CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor);
      } else if (state is ProfileError) {
        child = Text("Something Wrong Happened");
      } else if (state is ProfileLoaded) {
        title = state.user.name;
        child = _buildRewardBoard(state.rewards, state.score);
      }

      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        body: Center(child: child),
      );
    });
    // return Scaffold(
    //   appBar: AppBar(
    //       centerTitle: true,
    //       title: Text(
    //         "george moheb",
    //         style: TextStyle(fontWeight: FontWeight.bold),
    //       )),
    //   body: Center(child:
    //       BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
    //     if (state is ProfileEmpty) {
    //       profileBloc.add(FetchProfileEvent());
    //       return SizedBox.shrink();
    //     } else if (state is ProfileLoading) {
    //       return CircularProgressIndicator(
    //           backgroundColor: Theme.of(context).primaryColor);
    //     } else if (state is ProfileError) {
    //       return Text("Something Wrong Happened");
    //     } else if (state is ProfileLoaded) {
    //       return _buildRewardBoard(state.rewards, state.score);
    //     }
    //     return null;
    //   })),
    // );
  }

  Widget _buildRewardCard(Reward reward) {
    if (reward != null) {
      Color color = reward.color;
      bool isBrightColor =
          (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255 >
              0.5;
      Color textColor = isBrightColor ? Colors.black : Colors.white;
      return Card(
          elevation: 3,
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
