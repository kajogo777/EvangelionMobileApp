import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ch_app/src/data/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

import '../data/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showScanCodeButton = false;
  String _uriCode;
  StreamSubscription _sub;

  Future<bool> _confirmUsername(context, name) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueAccent,
          title: Text(
            'Verify',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: 'Are you ',
                      ),
                      TextSpan(
                        text: name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 17.0),
                      ),
                      TextSpan(
                        text: ' ?',
                      ),
                    ]))
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  _scanBarCode(context, scaffoldContext) async {
    setState(() {
      _showScanCodeButton = false;
    });

    String code = await FlutterBarcodeScanner.scanBarcode(
        "#" + Theme.of(context).primaryColor.value.toRadixString(16),
        "Cancel",
        false,
        ScanMode.QR);

    final isValidCode = await UserNetworkService.isValidCode(code);

    if (isValidCode) {
      await SecureStorageService.setAccessCode(code);
    } else {
      Scaffold.of(scaffoldContext).showSnackBar(new SnackBar(
        backgroundColor: Colors.redAccent,
        content: new Text(
          "Ops! Invalid Code",
          style: TextStyle(color: Colors.white),
        ),
      ));
      setState(() {
        _showScanCodeButton = true;
      });
      return;
    }

    final user = await UserNetworkService.fetchUser();

    final confirmed = await _confirmUsername(context, user.name);

    if (!confirmed) {
      SecureStorageService.clear();

      Scaffold.of(scaffoldContext).showSnackBar(new SnackBar(
        backgroundColor: Colors.blueAccent,
        content: new Text("Ops! Please Try Again"),
      ));
      setState(() {
        _showScanCodeButton = true;
      });
      return;
    }

    Navigator.pushReplacementNamed(context, '/main');
  }

  _checkCode(code, context) async {
    setState(() {
      _showScanCodeButton = false;
    });

    final isValidCode = await UserNetworkService.isValidCode(code);

    if (isValidCode) {
      await SecureStorageService.setAccessCode(code);
    } else {
      setState(() {
        _uriCode = null;
        _showScanCodeButton = true;
      });
      return;
    }

    final user = await UserNetworkService.fetchUser();

    final confirmed = await _confirmUsername(context, user.name);

    if (!confirmed) {
      SecureStorageService.clear();
      setState(() {
        _uriCode = null;
        _showScanCodeButton = true;
      });
      return;
    }

    Navigator.pushReplacementNamed(context, '/main');
  }

  Future<Null> initUniLinks() async {
    String code;

    try {
      Uri initialUri = await getInitialUri();
      code = initialUri?.pathSegments?.first;
      if (code != null)
        setState(() {
          _uriCode = code;
        });
    } on PlatformException {
      code = null;
    } on FormatException {
      code = null;
    } on StateError {
      code = null;
    }

    _sub = getUriLinksStream().listen((Uri uri) {
      code = uri?.pathSegments?.first;
      if (code != null)
        setState(() {
          _uriCode = code;
        });
    }, onError: (err) {});
  }

  _skipLogin() async {
    await initUniLinks();
    final code = await SecureStorageService.getAccessCode();
    if (code != null && await UserNetworkService.isValidCode(code)) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _showScanCodeButton = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _skipLogin();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uriCode != null) {
      _checkCode(_uriCode, context);
    }
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Theme.of(context).primaryColor, //Colors.white,
        body: Builder(
            builder: (scaffoldContext) => Column(
                  children: <Widget>[
                    new Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Text(
                          "EVANGELION",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        WavyHeader(),
                      ],
                    ),
                    Text(
                      "The Bible Is Personal",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    _showScanCodeButton
                        ? RaisedButton(
                            onPressed: () {
                              _scanBarCode(context, scaffoldContext);
                            },
                            child: Text('Scan Access Code',
                                style: TextStyle(fontSize: 20)),
                            color: Colors.blue[900])
                        : Expanded(
                            child: new LinearProgressIndicator(
                                backgroundColor: Colors.blue[900],
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.blue[300]))),
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: <Widget>[
                        WavyFooter(),
                        CircleDarkBlue(),
                        CircleBlue(),
                      ],
                    )
                  ],
                )));
  }
}

class WavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TopWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.lightGreen, Theme.of(context).primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.center),
        ),
        height: MediaQuery.of(context).size.height / 2.5,
      ),
    );
  }
}

class WavyFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FooterWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFFF9844),
            Color(0xFFFE8853),
            Color(0xFFFD7267),
          ], begin: Alignment.center, end: Alignment.bottomRight),
        ),
        height: MediaQuery.of(context).size.height / 3,
      ),
    );
  }
}

class CircleDarkBlue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-70.0, 90.0),
      child: Material(
        color: Colors.blue[900],
        child: Padding(padding: EdgeInsets.all(120)),
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 15.0)),
      ),
    );
  }
}

class CircleBlue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, 210.0),
      child: Material(
        color: Colors.blue[300],
        child: Padding(padding: EdgeInsets.all(140)),
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 15.0)),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This is where we decide what part of our image is going to be visible.
    var path = Path();
    path.lineTo(0.0, size.height);

    var firstControlPoint = new Offset(size.width / 7, size.height - 30);
    var firstEndPoint = new Offset(size.width / 6, size.height / 1.5);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 5, size.height / 4);
    var secondEndPoint = Offset(size.width / 1.5, size.height / 5);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint =
        Offset(size.width - (size.width / 9), size.height / 6);
    var thirdEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    ///move from bottom right to top
    path.lineTo(size.width, 0.0);

    ///finally close the path by reaching start point from top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FooterWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height - 60);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class YellowCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return null;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
