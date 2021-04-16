import 'package:flutter/material.dart';

import 'ui/navbar/tab_item.dart';
import 'ui/navbar/bottom_navigation.dart';

import 'ui/challenges/challenge_screen.dart';
import 'ui/profile/profile_screen.dart';
import 'ui/posts/posts_screen.dart';
import 'ui/main/connectivity.dart';
import 'package:ch_app/src/ui/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ch_app/src/blocs/challenge.dart';
import 'package:ch_app/src/blocs/post.dart';
import 'package:ch_app/src/blocs/post_details.dart';
import 'package:ch_app/src/blocs/profile.dart';
import 'package:ch_app/src/ui/posts/post_details.dart';
import 'data/repositories.dart';
import 'ui/login_screen.dart';
import 'ui/posts/post_details.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;

  // list tabs here
  final List<TabItem> tabs = [
    TabItem(
      tabName: "Challenges",
      icon: Icons.assignment,
      page: RequireConnectivity(
          child: BlocProvider(
        create: (context) => ChallengeBloc(
            challengeRepository:
                RepositoryProvider.of<ChallengeRepository>(context)),
        child: ChallengeScreen(),
      )),
    ),
    TabItem(
        tabName: "Posts",
        icon: Icons.archive,
        page: RequireConnectivity(
          child: BlocProvider(
            create: (context) => PostBloc(
                postRepository: RepositoryProvider.of<PostRepository>(context)),
            child: PostsScreen(),
          ),
        ),
        children: {
          "/post": RequireConnectivity(
            child: BlocProvider(
              create: (context) => PostDetailsBloc(
                  postRepository:
                      RepositoryProvider.of<PostRepository>(context)),
              child: PostDetails(),
            ),
          )
        }),
    TabItem(
      tabName: "Profile",
      icon: Icons.star,
      page: RequireConnectivity(
          child: BlocProvider(
        create: (context) => ProfileBloc(
            profileRepository:
                RepositoryProvider.of<ProfileRepository>(context),
            challengeRepository:
                RepositoryProvider.of<ChallengeRepository>(context)),
        child: ProfileScreen(),
      )),
    ),
  ];

  AppState() {
    // indexing is necessary for proper funcationality
    // of determining which tab is active
    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void _selectTab(int index) {
    if (index == currentTab) {
      // pop to first route
      // if the user taps on the active tab
      tabs[index].key.currentState.popUntil((route) => route.isFirst);
    } else {
      // update the state
      // in order to repaint
      setState(() => currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope handle android back btn

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
        '/main': (context) => WillPopScope(
              onWillPop: () async {
                final isFirstRouteInCurrentTab =
                    !await tabs[currentTab].key.currentState.maybePop();
                if (isFirstRouteInCurrentTab) {
                  // if not on the 'main' tab
                  if (currentTab != 0) {
                    // select 'main' tab
                    _selectTab(0);
                    // back button handled by app
                    return false;
                  }
                }
                // let system handle back button if we're on the first route
                return isFirstRouteInCurrentTab;
              },
              // this is the base scaffold
              // don't put appbar in here otherwise you might end up
              // with multiple appbars on one screen
              // eventually breaking the app
              child: Scaffold(
                // indexed stack shows only one child
                body: IndexedStack(
                  index: currentTab,
                  children: tabs.map((e) => e.page).toList(),
                ),
                // Bottom navigation
                bottomNavigationBar: BottomNavigation(
                  onSelectTab: _selectTab,
                  tabs: tabs,
                ),
              ),
            ),
      },
    );
  }
}
