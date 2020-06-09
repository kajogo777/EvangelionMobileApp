import 'package:flutter/material.dart';
import 'page_transformer.dart';
import 'main_menu_item.dart';

final menuItems = <ReadingModeItem>[
  new ReadingModeItem(
      description: 'Ready for a biblical adventure?',
      title: 'DAILY CHALLENGE',
      path: '/challenges',
      imageUrl: 'assets/gideon.jpg',
      enabled: true),
  new ReadingModeItem(
      description: 'Your spiritual mailbox.',
      title: 'POSTS',
      path: '/posts',
      imageUrl: 'assets/imprisoned.jpg',
      enabled: true),
  new ReadingModeItem(
      description: 'God knows how you feel.',
      title: 'MOODS\n(coming soon)',
      path: '/moods',
      imageUrl: 'assets/daniel1.jpg',
      enabled: false),
];

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PageTransformer(
        pageViewBuilder: (context, visibilityResolver) {
          return PageView.builder(
            controller:
                PageController(initialPage: 0, viewportFraction: 0.9 //0.85,
                    ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final pageVisibility =
                  visibilityResolver.resolvePageVisibility(index);

              return MainPageItem(
                item: item,
                pageVisibility: pageVisibility,
              );
            },
          );
        },
      ),
    );
  }
}
