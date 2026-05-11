import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:securemail/features/mailboxes/models/mailbox_model.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox_shared_widgets.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/Step2ImapScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/constants/ApiConstants.dart';


import 'package:securemail/core/extensions/context_snack_bar.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/step_scaffold.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class Step1ProviderScreen extends ConsumerStatefulWidget {
  const Step1ProviderScreen({super.key});

  @override
  ConsumerState<Step1ProviderScreen> createState() =>
      _Step1ProviderScreenState();
}

class _Step1ProviderScreenState extends ConsumerState<Step1ProviderScreen> {
  final _nameCtrl = TextEditingController();
  MailboxProvider _selected = MailboxProvider.gmail;

  /// Tracks whether we already restored form data from the provider
  /// to avoid overwriting on subsequent didChangeDependencies calls.
  bool _restoredFromProvider = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredFromProvider) return;

    final existing = ref.read(addMailboxFormProvider);
    if (existing.displayName != null) _nameCtrl.text = existing.displayName!;
    if (existing.provider != null) _selected = existing.provider!;
    _restoredFromProvider = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Please enter a mailbox name', isError: true);
      return;
    }

    ref.read(addMailboxFormProvider.notifier).updateStep1(
          displayName: name,
          provider: _selected,
        );

    if (_selected == MailboxProvider.imap) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const Step2ImapScreen()));
    } else if (_selected == MailboxProvider.gmail && !kIsWeb) {
      // ── Native Google Sign-In Flow for Mobile ────────────────
      final success = await ref.read(mailboxesProvider.notifier).connectGmailNative(displayName: name);
      if (success) {
        if (mounted) {
          ref.read(addMailboxFormProvider.notifier).reset();
          Navigator.of(context).pop();
        }
      }
    } else {
      // ── Browser OAuth Flow (Outlook & Web) ────────────────────
      final providerPath = _selected == MailboxProvider.gmail ? 'gmail' : 'outlook';
      
      String redirectUri;
      if (kIsWeb) {
        redirectUri = '${Uri.base.origin}/mailboxes/$providerPath/callback';
      } else {
        final baseUrl = ApiConstants.baseUrlDev; 
        redirectUri = '$baseUrl/mailboxes/$providerPath/callback';
      }
      
      final authUrl = await ref
          .read(mailboxesProvider.notifier)
          .getOAuthUrl(_selected, redirectUri);

      if (authUrl != null) {
        final uri = Uri.parse(authUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            context.showSnackBar('Could not launch login page', isError: true);
          }
        }
      } else {
        if (mounted) {
          context.showSnackBar('Failed to initialize connection', isError: true);
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      currentStep: 1,
      title: 'Step 1: Basic Info',
      subtitle:
          'Identify your new connection and select a service provider.',
      onBack: () => Navigator.of(context).pop(),
      onNext: _next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mailbox Name
          const SectionLabel('MAILBOX NAME'),
          const SizedBox(height: AppSpacing.x3),
          TextFormField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyM.copyWith(color: context.text1),
            decoration:
                stepInputDecoration(context, 'e.g. Sales Inbound'),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Provider Selection
          const SectionLabel('SELECT PROVIDER'),
          const SizedBox(height: AppSpacing.x3),
          _ProviderTile(
            value: MailboxProvider.gmail,
            selected: _selected,
            icon: const GmailIcon(),
            title: 'Gmail',
            subtitle: 'Fast & Secure Google Login',
            onTap: () =>
                setState(() => _selected = MailboxProvider.gmail),
          ),
          const SizedBox(height: 12),
          _ProviderTile(
            value: MailboxProvider.outlook,
            selected: _selected,
            icon: const OutlookIcon(),
            title: 'Outlook',
            subtitle: 'Microsoft 365 & Live accounts',
            onTap: () =>
                setState(() => _selected = MailboxProvider.outlook),
          ),
          const SizedBox(height: 12),
          _ProviderTile(
            value: MailboxProvider.imap,
            selected: _selected,
            icon: const CustomIcon(),
            title: 'Custom (SMTP/IMAP)',
            subtitle: 'Private servers and other hosts',
            onTap: () =>
                setState(() => _selected = MailboxProvider.imap),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}

// ─── Provider Tile ────────────────────────────────────────

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.value,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final MailboxProvider value;
  final MailboxProvider selected;
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? context.button1.withOpacity(0.08) : context.fieldBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? context.button1 : context.fieldBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppSpacing.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyM.copyWith(
                        color: context.text1,
                        fontWeight: FontWeight.w500,
                      )),
                  Text(subtitle,
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.text3,
                      )),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.button1 : context.text3,
                  width: 2,
                ),
                color: isSelected ? context.button1 : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
