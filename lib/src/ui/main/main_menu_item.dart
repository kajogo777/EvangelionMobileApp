import 'package:flutter/material.dart';
import 'page_transformer.dart';

class ReadingModeItem {
  ReadingModeItem({
    this.description,
    this.title,
    this.path,
    this.imageUrl,
    this.enabled,
  });

  final String description;
  final String title;
  final String path;
  final String imageUrl;
  final bool enabled;
}

class MainPageItem extends StatelessWidget {
  MainPageItem({
    @required this.item,
    @required this.pageVisibility,
  });

  final ReadingModeItem item;
  final PageVisibility pageVisibility;

  Widget _applyTextEffects({
    @required double translationFactor,
    @required Widget child,
  }) {
    final double xTranslation = pageVisibility.pagePosition * translationFactor;

    return Opacity(
      opacity: pageVisibility.visibleFraction,
      child: Transform(
        alignment: FractionalOffset.topLeft,
        transform: Matrix4.translationValues(
          xTranslation,
          0.0,
          0.0,
        ),
        child: child,
      ),
    );
  }

  _buildTextContainer(BuildContext context) {
    var appTheme = Theme.of(context);
    var titleText = _applyTextEffects(
      translationFactor: 300.0,
      child: Text(
        item.title,
        style: appTheme.textTheme.caption.copyWith(
          color: appTheme.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 20.0,
        ),
        textAlign: TextAlign.center,
      ),
    );

    var descriptionText = _applyTextEffects(
      translationFactor: 200.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          item.description,
          style: appTheme.textTheme.title.copyWith(
            color: appTheme.accentColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Positioned(
      bottom: 56.0,
      left: 32.0,
      right: 32.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleText,
          descriptionText,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var image = Image.asset(
      item.imageUrl,
      fit: BoxFit.cover,
      alignment: FractionalOffset(
        0.5 + (pageVisibility.pagePosition / 3),
        0.5,
      ),
    );

    var imageOverlayGradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.bottomCenter,
          end: FractionalOffset.topCenter,
          colors: [
            const Color(0xBB000000),
            const Color(0x00000000),
          ],
        ),
      ),
    );

    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 35.0,
          horizontal: 8.0,
        ),
        child: GestureDetector(
          onTap: () {
            if (this.item.enabled) Navigator.pushNamed(context, this.item.path);
          },
          child: Material(
            // shadowColor: Theme.of(context).primaryColor,
            shadowColor: Colors.white,
            elevation: 3.0,
            // borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                imageOverlayGradient,
                _buildTextContainer(context),
              ],
            ),
          ),
        ));
  }
}
