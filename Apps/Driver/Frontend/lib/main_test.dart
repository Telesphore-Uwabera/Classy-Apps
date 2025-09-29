import 'package:flutter/material.dart';

void main() {
  runApp(MyTestApp());
}

class MyTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Driver App Test',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
