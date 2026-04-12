import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

/// Reusable gradient background used across all Auth screens.
/// Extracted from: SplashScreen, LoginScreen, RegisterScreen, ChangePasswordScreen
///
/// Usage:
/// ```dart
/// return Scaffold(
///   body: AuthGradientBackground(
///     child: SafeArea(child: ...),
///   ),
/// );
/// ```
class AuthGradientBackground extends StatelessWidget {
  const AuthGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: context.isDark
              ? [
                  const Color.fromARGB(181, 17, 52, 43),
                  const Color.fromARGB(255, 3, 13, 10),
                  const Color.fromARGB(136, 17, 52, 43),
                ]
              : [
                  const Color(0xFFF2FBF7),
                  const Color(0xFFE8F6F2),
                  const Color(0xFFF2FBF7),
                ],
        ),
      ),
      child: child,
    );
  }
}
