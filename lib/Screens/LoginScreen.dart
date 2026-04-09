import 'package:flutter/material.dart';
import 'package:securemail/core/global/theme/app_color/AppColorLight.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: استبدل بـ auth logic بتاعك
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      // TODO: Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    _buildTitle(),
                    const SizedBox(height: 32),
                    _buildCard(),
                    const SizedBox(height: 20),
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

  Widget _buildLogo() {
    return Center(
        child: Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset('assets/splash.png', width: 24, height: 24),
    ));
  }

  // ── Title ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Center(
              child: Text(
                'Log in to your encrypted inbox',
                style: Theme.of(context).textTheme.displaySmall!)
            ),
          ),
        ],
      ),
    );
  }

  // ── Card ─────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSocialButtons(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 10),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMe(),
          const SizedBox(height: 20),
          _buildSignInButton(),
        ],
      ),
    );
  }

  // ── Email Field ───────────────────────────────────────────
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          decoration: _inputDecoration('Email'),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Email is required';
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  // ── Password Field ────────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          decoration: _inputDecoration('Password').copyWith(
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: const Color(0xFFABABAB),
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Password is required';
            if (val.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),
      ],
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
            activeColor: const Color(0xFF111111),
            side: BorderSide(color: Colors.black.withOpacity(0.2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            'Remember me for 30 days',
            style:
                TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.45)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to ForgotPasswordScreen
            },
            child: Text(
              'Forgot password?',
              style:
                  TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.45)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sign In Button ────────────────────────────────────────
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF111111).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Sign in',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.35)),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
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
            onTap: () {
              // TODO: Google Sign In
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _socialButton(
            label: 'Outlook',
            icon: const Icon(Icons.email, size: 20, color: Color(0xFF111111)),
            onTap: () {
              // TODO: Outlook Sign In
            },
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColorLight.buttonColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
          children: [
            const TextSpan(text: "Don't have an account? "),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to RegisterScreen
                },
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFABABAB), fontSize: 14),
      filled: true,
      fillColor: AppColorLight.buttonColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE24B4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
    );
  }
}
