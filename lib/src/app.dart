import 'package:ch_app/src/blocs/challenge.dart';
import 'package:ch_app/src/blocs/post.dart';
import 'package:ch_app/src/blocs/post_details.dart';
import 'package:ch_app/src/ui/login_screen.dart';
import 'package:ch_app/src/ui/posts/post_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories.dart';
import 'ui/login_screen.dart';
import 'ui/main/main_screen.dart';
import 'ui/main/connectivity.dart';
import 'ui/challenges/challenge_screen.dart';
import 'ui/moods/mood_screen.dart';
import 'ui/posts/posts_screen.dart';
import 'ui/posts/post_details.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[600],
        accentColor: Colors.white70,
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
        '/posts': (context) => RequireConnectivity(
              child: BlocProvider(
                create: (context) => PostBloc(
                    postRepository:
                        RepositoryProvider.of<PostRepository>(context)),
                child: PostsScreen(),
              ),
            ),
        '/post': (context) => RequireConnectivity(
              child: BlocProvider(
                create: (context) => PostDetailsBloc(
                    postRepository:
                        RepositoryProvider.of<PostRepository>(context)),
                child: PostDetails(),
              ),
            ),
      },
    );
  }
}
