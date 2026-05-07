import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/features/mailboxes/models/mailbox_model.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/router/app_router.dart';
import 'dart:convert';

class OAuthCallbackScreen extends ConsumerStatefulWidget {
  final String? code;
  final MailboxProvider? provider;

  const OAuthCallbackScreen({
    super.key,
    required this.code,
    required this.provider,
  });


  @override
  ConsumerState<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends ConsumerState<OAuthCallbackScreen> {
  bool _processing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    print('DEBUG: _handleCallback triggered');
    
    // Give router a moment to settle
    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.code == null) {
      print('DEBUG: Code is NULL');
      if (mounted) setState(() => _error = 'No authorization code received.');
      return;
    }

    if (mounted) setState(() => _processing = true);

    // Identify provider (Gmail/Outlook)
    MailboxProvider provider = widget.provider ?? MailboxProvider.gmail;
    final providerPath = provider == MailboxProvider.gmail ? 'gmail' : 'outlook';

    // Construct the redirect URI that was used
    final redirectUri = '${Uri.base.origin}/mailboxes/$providerPath/callback';

    print('--- OAuth Callback Start ---');
    print('Provider: $provider');
    print('Code: ${widget.code}');
    print('Redirect URI: $redirectUri');

    try {
      final success = await ref.read(mailboxesProvider.notifier).connectOAuth(
        provider: provider,
        code: widget.code!,
        redirectUri: redirectUri,
      );
      print('DEBUG: connectOAuth finished with success=$success');

      if (mounted) {
        if (success) {
          print('DEBUG: Navigating to mailboxes');
          context.go(AppRoutes.mailboxes);
        } else {
          final state = ref.read(mailboxesProvider);
          setState(() {
            _processing = false;
            _error = state.error ?? 'Failed to connect account.';
          });
        }
      }
    } catch (e) {
      print('DEBUG: Exception in _handleCallback: $e');
      if (mounted) {
        setState(() {
          _processing = false;
          _error = 'An unexpected error occurred: $e';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              if (_processing) ...[
                CircularProgressIndicator(color: context.button1),
                const SizedBox(height: 24),
                Text(
                  'Connecting your account...',
                  style: AppTextStyles.bodyL.copyWith(color: context.text1),
                ),
              ] else if (_error != null) ...[
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Connection Failed',
                  style: AppTextStyles.headingL.copyWith(color: context.text1),
                ),

                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM.copyWith(color: context.text3),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.mailboxes),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.button1,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Back to Mailboxes'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
