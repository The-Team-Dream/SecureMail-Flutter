import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_side_drawer.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/shared/widgets/app_border_outline.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';

class MailboxSettingsScreen extends ConsumerStatefulWidget {
  final int mailboxId;
  const MailboxSettingsScreen({super.key, required this.mailboxId});

  @override
  ConsumerState<MailboxSettingsScreen> createState() => _MailboxSettingsScreenState();
}

class _MailboxSettingsScreenState extends ConsumerState<MailboxSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameCtrl;
  bool _pushNotificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mailboxesState = ref.read(mailboxesProvider);
      final mailbox = mailboxesState.mailboxes.firstWhere(
        (m) => m.id == widget.mailboxId,
        orElse: () => mailboxesState.mailboxes.first,
      );
      _displayNameCtrl.text = mailbox.displayName;
      setState(() {
        _pushNotificationsEnabled = mailbox.pushNotificationsEnabled;
      });
    });
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(mailboxesProvider.notifier).updateMailboxSettings(
      widget.mailboxId,
      displayName: _displayNameCtrl.text.trim(),
      pushNotificationsEnabled: _pushNotificationsEnabled,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Settings updated successfully' : 'Failed to update settings',
            style: AppTextStyles.bodyM.copyWith(color: Colors.white),
          ),
          backgroundColor: success ? const Color(0xFF1F8A70) : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteMailbox() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.card1,
        title: Text(
          'Delete Mailbox',
          style: AppTextStyles.headingM.copyWith(color: context.text1),
        ),
        content: Text(
          'Are you sure you want to delete this mailbox? This action cannot be undone.',
          style: AppTextStyles.bodyM.copyWith(color: context.text3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelM.copyWith(color: context.text3),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelM.copyWith(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await ref.read(mailboxesProvider.notifier).removeMailbox(widget.mailboxId);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mailbox deleted successfully',
              style: AppTextStyles.bodyM.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1F8A70),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppRoutes.dashboard);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete mailbox',
              style: AppTextStyles.bodyM.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      drawer: MailboxSideDrawer(
        activeRoute: AppRoutes.mailboxSettings(widget.mailboxId),
        mailboxId: widget.mailboxId,
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                color: context.barBg,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                child: Row(
                  children: [
                    Builder(
                      builder: (scaffoldContext) {
                        return IconButton(
                          onPressed: () =>
                              Scaffold.of(scaffoldContext).openDrawer(),
                          icon: Icon(Icons.menu_rounded, color: context.text1),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mailbox Settings',
                      style: AppTextStyles.displayS.copyWith(
                        color: context.text1,
                        fontSize: 24,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      'Display Name',
                      style: AppTextStyles.labelM.copyWith(color: context.text2),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    TextFormField(
                      controller: _displayNameCtrl,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyles.inputText
                          .copyWith(color: context.fieldText),
                      decoration: appInputDecoration(context, 'Mailbox name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.x6),
                    _SettingSwitch(
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts when new email arrives.',
                      value: _pushNotificationsEnabled,
                      onChanged: (value) {
                        setState(() => _pushNotificationsEnabled = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.x8),
                    AppPrimaryButton(
                      label: 'Save Changes',
                      onPressed: _save,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.x6),
                    const Divider(),
                    const SizedBox(height: AppSpacing.x6),
                    Text(
                      'Danger Zone',
                      style: AppTextStyles.headingS.copyWith(color: Colors.redAccent),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      'Deleting this mailbox will stop synchronization and remove its local data. This action cannot be undone.',
                      style: AppTextStyles.bodyS.copyWith(color: context.text3),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.buttonHeightL,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteMailbox,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.withOpacity(0.1),
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          'Delete Mailbox',
                          style: AppTextStyles.labelL.copyWith(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.button1.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyM.copyWith(
                    color: context.text1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.text3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.button1,
          ),
        ],
      ),
    );
  }
}
