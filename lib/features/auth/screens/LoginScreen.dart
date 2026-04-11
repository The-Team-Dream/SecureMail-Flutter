import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';

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

    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          
          colors: context.isDark
              ? [
                  const Color.fromARGB(181, 17, 52, 43),
                  const Color.fromARGB(255, 3, 13, 10),
                  const Color.fromARGB(136, 17, 52, 43)
                ]
              : [
                  const Color(0xFFF2FBF7),
                  const Color(0xFFE8F6F2),
                  const Color(0xFFF2FBF7)
                ],
        ),
      ),
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
                      _buildError(error),
                    ],
                    const SizedBox(height: AppSpacing.x5),
                    _buildSignInButton(isLoading),
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
          label: 'Google',
          icon: const Icon(Icons.g_mobiledata,
              size: 20, color: Color(0xFF4285F4)),
          onTap: () {/* TODO: Google OAuth */},
        )),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
            child: _socialButton(
          label: 'Outlook',
          icon: Icon(Icons.email, size: 20, color: context.text1),
          onTap: () {/* TODO: Outlook OAuth */},
        )),
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
      decoration: _inputDecoration('Email'),
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
      decoration: _inputDecoration('Password').copyWith(
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

  // ── Error ─────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color: const Color(0xFFE24B4A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFE24B4A)),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
              child: Text(error,
                  style: AppTextStyles.bodyS
                      .copyWith(color: const Color(0xFFE24B4A)))),
        ],
      ),
    );
  }

  // ── Sign In Button ────────────────────────────────────────
  Widget _buildSignInButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.buttonHeightL,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text('Sign in',
                style: AppTextStyles.labelL.copyWith(color: Colors.white)),
      ),
    );
  }

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
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputPlaceholder
          .copyWith(color: context.fieldPlaceholder),
      filled: true,
      fillColor: context.fieldBg,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.fieldPaddingH,
          vertical: AppSpacing.fieldPaddingV),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.fieldBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.fieldBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.button1, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE24B4A))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
    );
  }
}
