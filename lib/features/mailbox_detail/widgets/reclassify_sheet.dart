import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';

class ReclassifySheet extends ConsumerWidget {
  const ReclassifySheet({super.key, required this.message, required this.currentFolder, this.onMoved});

  final MailboxMessage message;
  final String currentFolder;
  final VoidCallback? onMoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOptions = [
      (Icons.report_gmailerrorred_rounded, 'Spam', const Color(0xFFF4B400)),
      (Icons.bug_report_rounded, 'Malware', const Color(0xFFFF5252)),
      (Icons.phishing_rounded, 'Phishing', const Color(0xFF7B1FA2)),
      (Icons.verified_user_rounded, 'Clean / Safe', const Color(0xFF4CAF50)),
      (Icons.inbox_rounded, 'Inbox', const Color(0xFF03A9F4)),
    ];

    final options = allOptions.where((opt) {
      final label = opt.$2.toLowerCase();
      final current = currentFolder.toLowerCase();
      
      // Don't show the current folder
      if (label == current) return false;
      
      // If in Inbox, don't show Clean / Safe either
      if (current == 'inbox' && label == 'clean / safe') return false;
      
      return true;
    }).toList();

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Move to',
              style: AppTextStyles.headingS.copyWith(color: context.text1),
            ),
          ),
          ...options.map(
            (opt) => ListTile(
              leading: Icon(opt.$1, color: opt.$3),
              title: Text(
                opt.$2,
                style: AppTextStyles.bodyL.copyWith(color: context.text1),
              ),
              onTap: () async {
                final mbId = message.mailboxId;
                if (mbId == null) return;
                
                // Map 'Clean / Safe' to 'inbox' for the backend
                String target = opt.$2.toLowerCase();
                if (target == 'clean / safe') target = 'inbox';
                
                // Perform actual move
                await ref.read(messagesProvider.notifier).reclassifyMessage(
                  mbId, 
                  int.parse(message.id), 
                  target,
                );
                
                if (context.mounted) {
                  Navigator.pop(context); // Close sheet
                  onMoved?.call();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Message moved to ${opt.$2}'),
                      backgroundColor: opt.$3.withValues(alpha: 0.9),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          const _Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252)),
            title: Text(
              'Trash',
              style: AppTextStyles.bodyL.copyWith(color: const Color(0xFFFF5252)),
            ),
            onTap: () async {
              final mbId = message.mailboxId;
              if (mbId == null) return;

              await ref.read(messagesProvider.notifier).deleteMessage(
                mbId, 
                int.parse(message.id),
              );
              if (context.mounted) {
                Navigator.pop(context); // Close sheet
                onMoved?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message moved to Trash'),
                    backgroundColor: Color(0xFFFF5252),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: context.fieldBorder.withValues(alpha: 0.15),
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
