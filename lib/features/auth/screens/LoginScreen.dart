import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe      = false;
  bool _isLoading       = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
    context.go('/inbox');
    }
  }

  // ── Helper: يجيب الألوان الصح حسب الـ mode ───────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background           => _isDark ? AppColorDark.background            : AppColorLight.background;
  Color get _text1            => _isDark ? AppColorDark.text1            : AppColorLight.text1;
  Color get _text3            => _isDark ? AppColorDark.text3            : AppColorLight.text3;
  Color get _text4            => _isDark ? AppColorDark.text4            : AppColorLight.text4;
  Color get _button1          => _isDark ? AppColorDark.button1          : AppColorLight.button1;
  Color get _fieldBackground  => _isDark ? AppColorDark.fieldBackground  : AppColorLight.fieldBackground;
  Color get _fieldBorder      => _isDark ? AppColorDark.fieldBorder      : AppColorLight.fieldBorder;
  Color get _fieldPlaceholder => _isDark ? AppColorDark.fieldPlaceholder : AppColorLight.fieldPlaceholder;
  Color get _fieldText        => _isDark ? AppColorDark.fieldText        : AppColorLight.fieldText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical:   AppSpacing.screenVertical,
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
                    const SizedBox(height: AppSpacing.x5),
                    _buildSignInButton(),
                    const SizedBox(height: AppSpacing.x5),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: SizedBox(
        width:  90,
        height: 90,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.shield_outlined,
            size:  80,
            color: _button1,
          ),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.x4),
        Center(
          child: Text(
            'Welcome Back',
            style: AppTextStyles.displayS.copyWith(color: _text1),
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Center(
          child: Text(
            'Log in to your encrypted inbox',
            style: AppTextStyles.bodyM.copyWith(color: _text3),
          ),
        ),
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
            icon:  const Icon(Icons.g_mobiledata, size: 20, color: Color(0xFF4285F4)),
            onTap: () { /* TODO: Google Sign In */ },
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: _socialButton(
            label: 'Outlook',
            icon:  Icon(Icons.email, size: 20, color: _text1),
            onTap: () { /* TODO: Outlook Sign In */ },
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required String       label,
    required Widget       icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSize.buttonHeightM,
        decoration: BoxDecoration(
          color:        _fieldBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:       Border.all(color: _fieldBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacing.x2),
            Text(
              label,
              style: AppTextStyles.labelM.copyWith(color: _text1),
            ),
          ],
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: _fieldBorder.withOpacity(0.6))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text(
            'OR CONTINUE WITH',
            style: AppTextStyles.labelS.copyWith(color: _text3),
          ),
        ),
        Expanded(child: Divider(color: _fieldBorder.withOpacity(0.6))),
      ],
    );
  }

  // ── Email Field ───────────────────────────────────────────
  Widget _buildEmailField() {
    return TextFormField(
      controller:      _emailCtrl,
      keyboardType:    TextInputType.emailAddress,
      autocorrect:     false,
      textInputAction: TextInputAction.next,
      style:           AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration:      _inputDecoration('Email'),
      validator:       Validators.email,
    );
  }

  // ── Password Field ────────────────────────────────────────
  Widget _buildPasswordField() {
    return TextFormField(
      controller:       _passwordCtrl,
      obscureText:      _obscurePassword,
      textInputAction:  TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style:            AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration: _inputDecoration('Password').copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size:  AppIconSize.sm,
            color: _fieldPlaceholder,
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
          width:  18,
          height: 18,
          child: Checkbox(
            value:       _rememberMe,
            onChanged:   (val) => setState(() => _rememberMe = val ?? false),
            activeColor: _button1,
            side:        BorderSide(color: _fieldBorder, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            'Remember me for 30 days',
            style: AppTextStyles.bodyS.copyWith(color: _text3),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () { /* TODO: ForgotPasswordScreen */ },
          child: Text(
            'Forgot password?',
            style: AppTextStyles.bodyS.copyWith(color: _text4),
          ),
        ),
      ],
    );
  }

  // ── Sign In Button ────────────────────────────────────────
  Widget _buildSignInButton() {
    return SizedBox(
      width:  double.infinity,
      height: AppSize.buttonHeightL,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // 👈 هنا الريدياس
        ),
      ),
        child: _isLoading
            ? const SizedBox(
                width:  20,
                height: 20,
                child:  CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                'Sign in',
                style: AppTextStyles.labelL.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(color: _text3),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: () { /* TODO: RegisterScreen */ },
                child: Text(
                  'Sign up',
                  style: AppTextStyles.bodyS.copyWith(
                    fontWeight: FontWeight.w600,
                    color:      _text4,
                  ),
                ),
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
      hintText:  hint,
      hintStyle: AppTextStyles.inputPlaceholder.copyWith(color: _fieldPlaceholder),
      filled:    true,
      fillColor: _fieldBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.fieldPaddingH,
        vertical:   AppSpacing.fieldPaddingV,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: _button1, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: Color(0xFFE24B4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
    );
  }
}