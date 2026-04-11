import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/features/auth/screens/SplashScreen.dart';
import 'package:securemail/features/auth/screens/LoginScreen.dart';
import 'package:securemail/features/auth/screens/RegisterScreen.dart';
import 'package:securemail/features/auth/screens/ForgotPasswordScreen.dart';
import 'package:securemail/features/auth/screens/OtpScreen.dart';
import 'package:securemail/features/dashboard/screens/DashboardScreen.dart';

class AppRoutes {
  AppRoutes._();

  // ── Route Names ───────────────────────────────────────────
  static const splash         = '/';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp            = '/otp';
  static const dashboard      = '/dashboard';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [

    // ── Splash ───────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Login ────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Register ─────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.register,
      builder: (_, __) => const RegisterScreen(),
    ),

    // ── Forgot Password ───────────────────────────────────────
    GoRoute(
      path:    AppRoutes.forgotPassword,
      builder: (_, __) => const ForgotPasswordScreen(),
    ),

    // ── OTP ───────────────────────────────────────────────────
    // بياخد email كـ extra عشان يبعته في الـ verify
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return OtpScreen(email: email);
      },
    ),

    // ── Dashboard ─────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.dashboard,
      builder: (_, __) => const NavbarRoots(),
    ),
  ],

  // ── Error Page ────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
