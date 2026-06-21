import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/enums/encryption_mode.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox_shared_widgets.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/Step3SmtpScreen.dart';

import 'package:securemail/features/mailboxes/screens/add_mailbox/step_scaffold.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';


class Step2ImapScreen extends ConsumerStatefulWidget {
  const Step2ImapScreen({super.key});
  @override
  ConsumerState<Step2ImapScreen> createState() => _Step2ImapScreenState();
}
class _Step2ImapScreenState extends ConsumerState<Step2ImapScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostCtrl = TextEditingController(text: '');
  final _portCtrl = TextEditingController(text: '993');
  final _userCtrl = TextEditingController(text: '');
  final _passCtrl = TextEditingController(text: '');

  EncryptionMode _encryption = EncryptionMode.sslTls;
  bool _obscurePass = true;
  bool _restoredFromProvider = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredFromProvider) return;

    final existing = ref.read(addMailboxFormProvider);
    if (existing.imapHost != null) _hostCtrl.text = existing.imapHost!;
    if (existing.imapPort != null) {
      _portCtrl.text = existing.imapPort.toString();
    }
    if (existing.email != null) _userCtrl.text = existing.email!;
    if (existing.imapEncryption != null) {
      _encryption = existing.imapEncryption!;
    }
    _restoredFromProvider = true;
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(addMailboxFormProvider.notifier).updateStep2(
          email: _userCtrl.text.trim(),
          imapHost: _hostCtrl.text.trim(),
          imapPort: int.tryParse(_portCtrl.text) ?? 993,
          imapEncryption: _encryption,
          imapPassword: _passCtrl.text,
          smtpHost: _hostCtrl.text.trim().replaceFirst('imap.', 'smtp.'),
          smtpPort: 465,
          smtpEncryption: _encryption,
          smtpPassword: _passCtrl.text,
        );

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const Step3SmtpScreen()));
  }

  /// Port number validator — ensures it's a valid port (1-65535).
  String? _portValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final port = int.tryParse(v);
    if (port == null) return 'Must be a number';
    if (port < 1 || port > 65535) return 'Port must be 1–65535';
    return null;
  }

  /// Email validator — basic format check.
  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      currentStep: 2,
      title: 'IMAP Configuration',
      subtitle: 'Enter your incoming server details.',
      onBack: () => Navigator.of(context).pop(),
      onNext: _next,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel('IMAP HOST'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _hostCtrl,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(context, 'imap.example.com'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            SectionLabel('PORT'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _portCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(context, '993'),
              validator: _portValidator,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            SectionLabel('ENCRYPTION'),
            const SizedBox(height: AppSpacing.x3),
            EncryptionToggle<EncryptionMode>(
              values: EncryptionMode.values,
              selected: _encryption,
              labels: {
                EncryptionMode.none: EncryptionMode.none.label,
                EncryptionMode.sslTls: EncryptionMode.sslTls.label,
                EncryptionMode.startTls: EncryptionMode.startTls.label,
              },
              onChanged: (v) => setState(() => _encryption = v),
            ),
            const SizedBox(height: AppSpacing.itemGap),

            SectionLabel('EMAIL / USERNAME'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _userCtrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(
                context,
                'user@domain.com',
                prefix: Icon(Icons.person_outline,
                    size: AppIconSize.md, color: context.text3),
              ),
              validator: _emailValidator,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            SectionLabel('APP PASSWORD'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(
                context,
                '••••••••••••',
                prefix: Icon(Icons.lock_outline,
                    size: AppIconSize.md, color: context.text3),
                suffix: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  child: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: AppIconSize.md,
                    color: context.text3,
                  ),
                ),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sectionGap * 1.5),
          ],
        ),
      ),
    );
  }
}
