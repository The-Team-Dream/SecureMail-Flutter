import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        MailboxMockMessages.inbox.where((m) => m.isActive).length;

    return MailboxFolderScaffold(
      title: 'Inbox',
      activeRoute: AppRoutes.inbox,
      messages: MailboxMockMessages.inbox,
      showFilters: true,
      unreadCount: unreadCount,
      showRiskBadge: false,
    );
  }
}
