import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';
import 'package:securemail/shared/widgets/app_border_outline.dart';
import 'package:securemail/shared/widgets/app_error_banner.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    if (success) {
      final authState = ref.read(authProvider);
      if (authState.requiresVerification) {
        final email = authState.pendingEmail ?? _emailCtrl.text.trim();
        ref.read(authProvider.notifier).clearVerificationFlag();
        context.push(AppRoutes.otp, extra: email);
        return;
      }
      if (!authState.requiresVerification && authState.isAuthenticated) {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return Scaffold(
        body: AuthGradientBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenVertical,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    _buildTitle(),
                    const SizedBox(height: AppSpacing.x8),
                    _buildSocialButtons(),
                    const SizedBox(height: AppSpacing.x5),
                    _buildDivider(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildEmailField(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildPasswordField(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildRememberMe(),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.x3),
                      AppErrorBanner(message: error),
                    ],
                    const SizedBox(height: AppSpacing.x5),
                    AppPrimaryButton(
                      label: 'Sign in',
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    _buildFooter(),
                    const SizedBox(height: AppSpacing.x12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: SizedBox(
        width: 90,
        height: 90,
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.shield_outlined, size: 80, color: context.button1),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        Center(
            child: Text('Welcome Back',
                style: AppTextStyles.displayS.copyWith(color: context.text1))),
        Center(
            child: Text('Log in to your encrypted inbox',
                style: AppTextStyles.bodyM.copyWith(color: context.text3))),
        const SizedBox(height: AppSpacing.x16),
      ],
    );
  }

  // ── Social Buttons ────────────────────────────────────────
  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
            child: _socialButton(
          label: 'Sign in with Google',
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 20,
            height: 20,
          ),
          onTap: () async {
            final success = await ref.read(authProvider.notifier).loginWithGoogle();
            if (success && mounted) {
              context.go(AppRoutes.dashboard);
            }
          },
        )),
        const SizedBox(width: AppSpacing.x3),
        
      ],
    );
  }

  Widget _socialButton(
      {required String label,
      required Widget icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSize.buttonHeightM,
        decoration: BoxDecoration(
          color: context.fieldBg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacing.x2),
            Text(label,
                style: AppTextStyles.labelM.copyWith(color: context.text1)),
          ],
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: context.fieldBorder.withOpacity(0.6))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text('OR CONTINUE WITH',
              style: AppTextStyles.labelS.copyWith(color: context.text3)),
        ),
        Expanded(child: Divider(color: context.fieldBorder.withOpacity(0.6))),
      ],
    );
  }

  // ── Fields ────────────────────────────────────────────────
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration: appInputDecoration(context, 'Email'),
      validator: Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration: appInputDecoration(context, 'Password').copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: AppIconSize.sm,
            color: context.fieldPlaceholder,
          ),
        ),
      ),
      validator: Validators.password,
    );
  }

  // ── Remember Me ───────────────────────────────────────────
  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (val) => setState(() => _rememberMe = val ?? false),
            activeColor: context.button1,
            side: BorderSide(color: context.fieldBorder, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xs)),
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text('Remember me for 30 days',
              style: AppTextStyles.bodyS.copyWith(color: context.text3)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.push(AppRoutes.forgotPassword),
          child: Text('Forgot password?',
              style: AppTextStyles.bodyS.copyWith(color: context.text4)),
        ),
      ],
    );
  }

  // ── Error → replaced by AppErrorBanner ──────────────────
  // ── Sign In Button → replaced by AppPrimaryButton ────────

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(color: context.text3),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.register),
                child: Text('Create Account',
                    style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w600, color: context.text4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input Decoration ──────────────────────────────────────
}
