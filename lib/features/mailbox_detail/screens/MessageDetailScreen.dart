import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/reclassify_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';

class MessageDetailScreen extends ConsumerStatefulWidget {
  const MessageDetailScreen({super.key, required this.message, this.currentFolder});

  final MailboxMessage message;
  final String? currentFolder;

  @override
  ConsumerState<MessageDetailScreen> createState() =>
      _MessageDetailScreenState();
}

class _MessageDetailScreenState extends ConsumerState<MessageDetailScreen> {
  bool _senderExpanded = false;
  bool _starred = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SubjectRow(
                    message: widget.message,
                    starred: _starred,
                    onStarTap: () => setState(() => _starred = !_starred),
                  ),
                  _SenderCard(
                    message: widget.message,
                    expanded: _senderExpanded,
                    onExpandTap: () =>
                        setState(() => _senderExpanded = !_senderExpanded),
                  ),
                  const _Divider(),
                  _MessageBody(message: widget.message),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (widget.currentFolder != 'Sent')
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: context.bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: _ActionButtons(
                  message: widget.message,
                  currentFolder: widget.currentFolder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.bgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: context.text1, size: 22),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: 'Archive',
          icon: Icon(Icons.archive_outlined, color: context.text2, size: 22),
        ),
        IconButton(
          onPressed: () async {
            await ref
                .read(messagesProvider.notifier)
                .deleteMessage(widget.message);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message deleted'),
                  backgroundColor: Color(0xFFFF5252),
                ),
              );
            }
          },
          tooltip: 'Delete',
          icon: Icon(Icons.delete_outline_rounded,
              color: context.text2, size: 22),
        ),
        IconButton(
          onPressed: () {},
          tooltip: 'Mark as unread',
          icon:
              Icon(Icons.mail_outline_rounded, color: context.text2, size: 22),
        ),
        IconButton(
          onPressed: () => _showMoreMenu(context),
          tooltip: 'More',
          icon: Icon(Icons.more_vert_rounded, color: context.text2, size: 22),
        ),
      ],
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MoreMenuSheet(textColor: context.text1),
    );
  }
}

// ── Subject Row ────────────────────────────────────────────

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.message,
    required this.starred,
    required this.onStarTap,
  });

  final MailboxMessage message;
  final bool starred;
  final VoidCallback onStarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message.subject,
              style: AppTextStyles.headingL.copyWith(
                color: context.text1,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          IconButton(
            onPressed: onStarTap,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              starred ? Icons.star_rounded : Icons.star_outline_rounded,
              color: starred ? const Color(0xFFF4B400) : context.text3,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sender Card ────────────────────────────────────────────

class _SenderCard extends StatelessWidget {
  const _SenderCard({
    required this.message,
    required this.expanded,
    required this.onExpandTap,
  });

  final MailboxMessage message;
  final bool expanded;
  final VoidCallback onExpandTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(message: message),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        message.sender.contains('<')
                            ? message.sender.split('<')[0].trim()
                            : message.sender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyL.copyWith(
                          color: context.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.timeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: context.text3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onExpandTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'to me',
                          style: AppTextStyles.bodyS
                              .copyWith(color: context.text3),
                        ),
                        Icon(
                          expanded
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: context.text3,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 8),
                  _DetailRow(label: 'from', value: message.sender),
                  _DetailRow(label: 'to', value: 'me'),
                  _DetailRow(label: 'date', value: message.timeLabel),
                ],
                const SizedBox(height: 8),
                _SecurityBadge(message: message),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.reply_rounded, color: context.text3, size: 20),
              ),
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.more_vert_rounded,
                    color: context.text3, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: AppTextStyles.bodyS
                  .copyWith(color: context.text3, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyS
                  .copyWith(color: context.text2, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.message});

  final MailboxMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: message.badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: message.badgeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded,
              size: 11, color: message.badgeColor),
          const SizedBox(width: 5),
          Text(
            message.badgeLabel,
            style: AppTextStyles.labelS.copyWith(
              color: message.badgeColor,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Body ───────────────────────────────────────────

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.message});

  final MailboxMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Text(
        '${message.preview}\n\n'
        'This is a simulated secure message content. In a real application, '
        'this would be the full decrypted body of the email.\n\n'
        'SecureMail ensures that your communication remains private and verified.',
        style: AppTextStyles.bodyL.copyWith(
          color: context.text2,
          height: 1.6,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ── Action Buttons ─────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.message, this.currentFolder});

  final MailboxMessage message;
  final String? currentFolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _GmailButton(
            onPressed: () {
              String recipient = message.sender;
              if (recipient.contains('<') && recipient.contains('>')) {
                recipient = recipient.split('<')[1].split('>')[0];
              }
              context.push(
                AppRoutes.compose,
                extra: {
                  'recipient': recipient,
                  'subject': 'Re: ${message.subject}',
                },
              );
            },
            icon: Icons.reply_rounded,
            label: 'Reply',
          ),
          const SizedBox(width: 12),
          _GmailButton(
            onPressed: () => _showReclassifyMenu(context),
            icon: Icons.security_rounded,
            label: 'Reclassified',
          ),
        ],
      ),
    );
  }

  void _showReclassifyMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ReclassifySheet(
        message: message,
        currentFolder: currentFolder ?? 'Inbox',
      ),
    );
  }
}


class _GmailButton extends StatelessWidget {
  const _GmailButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(
          label,
          style: AppTextStyles.labelM.copyWith(color: context.text2),
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.text2,
          side: BorderSide(color: context.fieldBorder.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

// ── Divider ────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: context.fieldBorder.withValues(alpha: 0.15),
      height: 1,
      indent: 18,
      endIndent: 18,
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.message});

  final MailboxMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: message.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        message.initials,
        style: AppTextStyles.headingS.copyWith(
          color: message.badgeColor == const Color(0xFFFF5252)
              ? const Color(0xFFFF5252)
              : context.button1,
          fontWeight: FontWeight.w800,
          fontSize: 15,
          height: 1,
        ),
      ),
    );
  }
}

// ── More Menu Bottom Sheet ─────────────────────────────────

class _MoreMenuSheet extends StatelessWidget {
  const _MoreMenuSheet({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.label_outline_rounded, 'Label'),
      (Icons.block_rounded, 'Block sender'),
      (Icons.report_gmailerrorred_rounded, 'Report phishing'),
      (Icons.print_outlined, 'Print'),
    ];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.fieldBorder.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.$1, color: context.text2, size: 22),
              title: Text(
                item.$2,
                style: AppTextStyles.bodyL.copyWith(color: context.text1),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
