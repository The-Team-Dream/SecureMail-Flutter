import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

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
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
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
    return Scaffold(
      
      body:AuthGradientBackground(child:  FadeTransition(
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
                      _buildLogo(),
                      const SizedBox(height: AppSpacing.x8),
                      _buildAppName(),
                      const SizedBox(height: AppSpacing.x2),
                      Text(
                        'QUANTUM-ENCRYPTED MESSAGING',
                        style: AppTextStyles.labelS.copyWith(
                          color: context.text3,
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
                      _buildProgressSection(),
                      const SizedBox(height: AppSpacing.x8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
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
        'assets/images/splash.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackLogo(),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: context.button1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: context.button1.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.shield_outlined,
        size: 80,
        color: context.button1,
      ),
    );
  }

  // ── App Name ───────────────────────────────────────────────
  Widget _buildAppName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SECURE',
          style: AppTextStyles.displayM.copyWith(
            color: context.text1,
            letterSpacing: 6,
            fontSize: 28,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'MAIL',
          style: AppTextStyles.displayM.copyWith(
            color: context.button1,
            letterSpacing: 6,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  // ── Progress Section ───────────────────────────────────────
  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (_, __) {
        final percent = (_progressAnim.value * 100).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYSTEM INTEGRITY CHECK',
                  style: AppTextStyles.labelS.copyWith(
                    color: context.text3,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '$percent%',
                  style: AppTextStyles.labelS.copyWith(
                    color: context.text3,
                    letterSpacing: 1,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),

            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: context.card2,
                valueColor: AlwaysStoppedAnimation<Color>(context.button1),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.x3),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: context.text3,
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  _statusText,
                  style: AppTextStyles.labelS.copyWith(
                    color: context.text3,
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