import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';

/// Reusable 80×80 rounded icon container used in Auth screens.
/// Extracted from: ForgotPasswordScreen (×2), OtpScreen (×1)
///
/// Usage:
/// ```dart
/// AuthIconBox(icon: Icons.lock_reset_outlined)
/// ```
class AuthIconBox extends StatelessWidget {
  const AuthIconBox({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  80,
      height: 80,
      decoration: BoxDecoration(
        color:        context.button1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border:       Border.all(color: context.button1.withOpacity(0.3)),
      ),
      child: Icon(icon, size: 40, color: context.button1),
    );
  }
}
