import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

class RequireConnectivity extends StatelessWidget {
  final Widget child;
  const RequireConnectivity({Key key, @required this.child})
      : assert(child != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          if (connectivity == ConnectivityResult.none) {
            return Material(
                child: Container(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(
                      Icons.cloud_off,
                      size: 150.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text.rich(
                      TextSpan(text: "Ops!\nUnable to connect to the Internet"),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                    )
                  ])),
            ));
          } else {
            return child;
          }
        },
        child: child);
  }
}
