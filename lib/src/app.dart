import 'package:ch_app/src/blocs/blocs.dart';
import 'package:ch_app/src/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories.dart';
import 'ui/login_screen.dart';
import 'ui/main/main_screen.dart';
import 'ui/main/connectivity.dart';
import 'ui/challenges/challenge_screen.dart';
import 'ui/moods/mood_screen.dart';
import 'ui/issues/issue_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[600],
        accentColor: Colors.white,
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RequireConnectivity(child: LoginScreen()),
        '/main': (context) => RequireConnectivity(child: MainScreen()),
        '/challenges': (context) => RequireConnectivity(
                child: BlocProvider(
              create: (context) => ChallengeBloc(
                  challengeRepository:
                      RepositoryProvider.of<ChallengeRepository>(context)),
              child: ChallengeScreen(),
            )),
        '/moods': (context) => MoodScreen(),
        '/issues': (context) => IssueScreen(),
      },
    );
  }
}
