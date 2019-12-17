import 'package:flutter/material.dart';

class Bible extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bible"),
      ),
      body: Center(
        child: Text('scripture here'),
      ),
    );
  }
}
