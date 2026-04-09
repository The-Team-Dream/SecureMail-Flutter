import 'package:flutter/material.dart';
import 'package:securemail/Screens/WelcomeScreen.dart';
import 'package:securemail/core/global/theme/theme_data/ThemeDataLight.dart';
  


void main() {
  runApp( SecurMail ());
}

class SecurMail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecurMail',
      theme: getThemeLight(), 
      home:WelcomeScreen(),
    );
  }
}
