import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColorDark.background : AppColorLight.background;
    final text   = isDark ? AppColorDark.text1      : AppColorLight.text1;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Text(
          '🎉 Welcome to SecureMail!',
          style: TextStyle(fontSize: 20, color: text, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
