import 'package:flutter/material.dart';
import 'Screens/SplashScreen.dart';


void main() {
  runApp( SecurMail ());
}

class SecurMail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecurMail',
      theme: ThemeData(primarySwatch: Colors.blue) ,
      home:SplashScreen(),
    );
  }
}
// test
// test 2