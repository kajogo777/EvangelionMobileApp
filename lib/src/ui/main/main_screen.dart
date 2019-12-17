import 'package:flutter/material.dart';
import 'main_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _children = [
    null, //Bible(),
    MainMenu(),
    null,
  ];

  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor.withAlpha(150),
      body: Center(child: _children[_currentIndex]),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.book),
      //       title: Text('My Bible'),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       title: Text('Home'),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.comment),
      //       title: Text('Groups'),
      //     ),
      //   ],
      //   selectedItemColor: Theme.of(context).primaryColor,
      //   currentIndex: _currentIndex,
      //   onTap: _onTabTapped,
      // ),
    );
  }
}
