import 'package:ch_app/src/app.dart';
import 'package:flutter/material.dart';
import 'tab_item.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({
    this.onSelectTab,
    this.tabs,
  });
  final ValueChanged<int> onSelectTab;
  final List<TabItem> tabs;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      items: tabs
          .map(
            (e) => _buildItem(
                index: e.getIndex(), icon: e.icon, tabName: e.tabName),
          )
          .toList(),
      onTap: (index) => onSelectTab(
        index,
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
      {int index, IconData icon, String tabName}) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _tabColor(index: index),
      ),
      title: Text(
        tabName,
        style: TextStyle(
          color: _tabColor(index: index),
          fontSize: 12,
        ),
      ),
    );
  }

  Color _tabColor({int index}) {
    return AppState.currentTab == index ? Colors.white : Colors.white54;
  }
}
