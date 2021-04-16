import 'package:flutter/material.dart';
import 'package:ch_app/src/app.dart';

class TabItem {
  // you can customize what kind of information is needed
  // for each tab
  final String tabName;
  final IconData icon;
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  int _index = 0;
  Widget _page;
  Map<String, Widget> _children;

  TabItem(
      {@required this.tabName,
      @required this.icon,
      @required Widget page,
      Map<String, Widget> children}) {
    _page = page;
    _children = children;
  }

  // I was getting a weird warning when using getters and setters for _index
  // so I converted them to functions

  // used to set the index of this tab
  // which will be used in identifying if this tab is active
  void setIndex(int i) {
    _index = i;
  }

  int getIndex() => _index;

// adds a wrapper around the page widgets for visibility
// visibility widget removes unnecessary problems
// like interactivity and animations when the page is inactive
  Widget get page {
    return Visibility(
      // only paint this page when currentTab is active
      visible: _index == AppState.currentTab,
      // important to preserve state while switching between tabs
      maintainState: true,
      child: Navigator(
        // key tracks state changes
        key: key,
        onGenerateRoute: (routeSettings) {
          if (_children != null && _children.containsKey(routeSettings.name)) {
            return MaterialPageRoute(
                builder: (_) => _children[routeSettings.name],
                settings: routeSettings);
          }

          return MaterialPageRoute(
            builder: (_) => _page,
          );
        },
      ),
    );
  }
}
