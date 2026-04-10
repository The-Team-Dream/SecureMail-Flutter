import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _progressAnim;
  late final Animation<double> _fadeAnim;

  String _statusText = 'INITIALIZING BIOMETRICS';

  final List<_CheckStep> _steps = [
    _CheckStep(label: 'INITIALIZING BIOMETRICS', target: 0.30),
    _CheckStep(label: 'VERIFYING ENCRYPTION KEYS', target: 0.60),
    _CheckStep(label: 'SYSTEM INTEGRITY CHECK', target: 0.88),
    _CheckStep(label: 'SECURING CONNECTION', target: 1.00),
  ];

  @override
  void initState() {
    super.initState();

    // Fade in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    // Progress bar
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    _progressCtrl.addListener(_updateStatus);
    _progressCtrl.forward();

    // Navigate after animation
    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  void _updateStatus() {
    final value = _progressAnim.value;
    for (final step in _steps.reversed) {
      if (value >= step.target - 0.30) {
        if (_statusText != step.label) {
          setState(() => _statusText = step.label);
        }
        break;
      }
    }
  }

  void _navigateNext() {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _progressCtrl.removeListener(_updateStatus);
    _progressCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColorDark.background : AppColorLight.background;
    final textPrimary = isDark ? AppColorDark.text1 : AppColorLight.text1;
    final textSecondary = isDark ? AppColorDark.text3 : AppColorLight.text3;
    final accentColor = isDark ? AppColorDark.button1 : AppColorLight.button1;
    final progressBg = isDark ? AppColorDark.card2 : AppColorLight.card2;

    return Scaffold(
      backgroundColor: bgColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              children: [
                // ── Logo Area ──────────────────────────────
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _buildLogo(),
                      const SizedBox(height: AppSpacing.x8),

                      // SECURE MAIL
                      _buildAppName(accentColor, textPrimary),
                      const SizedBox(height: AppSpacing.x2),

                      // Subtitle
                      Text(
                        'QUANTUM-ENCRYPTED MESSAGING',
                        style: AppTextStyles.labelS.copyWith(
                          color: textSecondary,
                          letterSpacing: 2.5,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress Area ──────────────────────────
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildProgressSection(
                        accentColor: accentColor,
                        progressBg: progressBg,
                        textSecondary: textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.x8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackLogo(),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    // لو الصورة مش موجودة بيعرض placeholder
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppColorLight.button1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColorLight.button1.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.shield_outlined,
        size: 80,
        color: AppColorLight.button1,
      ),
    );
  }

  // ── App Name ───────────────────────────────────────────────
  Widget _buildAppName(Color accentColor, Color textPrimary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SECURE',
          style: AppTextStyles.displayM.copyWith(
            color: textPrimary,
            letterSpacing: 6,
            fontSize: 28,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'MAIL',
          style: AppTextStyles.displayM.copyWith(
            color: accentColor,
            letterSpacing: 6,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  // ── Progress Section ───────────────────────────────────────
  Widget _buildProgressSection({
    required Color accentColor,
    required Color progressBg,
    required Color textSecondary,
  }) {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (_, __) {
        final percent = (_progressAnim.value * 100).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYSTEM INTEGRITY CHECK',
                  style: AppTextStyles.labelS.copyWith(
                    color: textSecondary,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '$percent%',
                  style: AppTextStyles.labelS.copyWith(
                    color: textSecondary,
                    letterSpacing: 1,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.x3),

            // Status Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: textSecondary,
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  _statusText,
                  style: AppTextStyles.labelS.copyWith(
                    color: textSecondary,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ── Helper ─────────────────────────────────────────────────
class _CheckStep {
  const _CheckStep({required this.label, required this.target});
  final String label;
  final double target;
}
