import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider).inbox;
    final unreadCount = messages.where((m) => m.isActive).length;

    return MailboxFolderScaffold(
      title: 'Inbox',
      activeRoute: AppRoutes.inbox,
      messages: messages,
      showFilters: true,
      unreadCount: unreadCount,
      showRiskBadge: false,
    );
  }
}
