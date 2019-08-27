import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../data/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showScanCodeButton = false;

  _scanBarCode(context, scaffoldContext) async {
    setState(() {
      _showScanCodeButton = false;
    });

    String code = await FlutterBarcodeScanner.scanBarcode(
        "#" + Theme.of(context).primaryColor.value.toRadixString(16),
        "Cancel",
        false);

    final isValidCode = await UserNetworkService.isValidCode(code);

    if (isValidCode) {
      await SecureStorageService.setAccessCode(code);
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Scaffold.of(scaffoldContext).showSnackBar(new SnackBar(
        backgroundColor: Colors.redAccent,
        content: new Text("Ops! Invalid Code"),
      ));
      setState(() {
        _showScanCodeButton = true;
      });
    }
  }

  _skipLogin() async {
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
  Widget build(BuildContext context) {
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
                            child: Container(),
                          ),
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

const List<Color> greenGradients = [
  Colors.lightGreen,
  Colors.green,
];

const List<Color> orangeGradients = [
  Color(0xFFFF9844),
  Color(0xFFFE8853),
  Color(0xFFFD7267),
];

class WavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TopWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: greenGradients,
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
          gradient: LinearGradient(
              colors: orangeGradients,
              begin: Alignment.center,
              end: Alignment.bottomRight),
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
