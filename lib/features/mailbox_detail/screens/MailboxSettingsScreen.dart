import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_side_drawer.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class MailboxSettingsScreen extends StatefulWidget {
  final int mailboxId;
  const MailboxSettingsScreen({super.key, required this.mailboxId});

  @override
  State<MailboxSettingsScreen> createState() => _MailboxSettingsScreenState();
}

class _MailboxSettingsScreenState extends State<MailboxSettingsScreen> {
  bool scanAttachments = true;
  bool quarantineThreats = true;
  bool encryptedBackups = true;



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
                    'Settings',
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
                  _SettingSwitch(
                    title: 'Scan attachments',
                    subtitle: 'Analyze every incoming file before delivery.',
                    value: scanAttachments,
                    onChanged: (value) {
                      setState(() => scanAttachments = value);
                    },
                  ),
                  _SettingSwitch(
                    title: 'Quarantine threats',
                    subtitle: 'Move suspicious emails out of the inbox.',
                    value: quarantineThreats,
                    onChanged: (value) {
                      setState(() => quarantineThreats = value);
                    },
                  ),
                  _SettingSwitch(
                    title: 'Encrypted backups',
                    subtitle: 'Store mailbox snapshots in encrypted storage.',
                    value: encryptedBackups,
                    onChanged: (value) {
                      setState(() => encryptedBackups = value);
                    },
                  ),
                ],
              ),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 12),
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
