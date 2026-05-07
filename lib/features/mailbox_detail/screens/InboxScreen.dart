import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class InboxScreen extends ConsumerStatefulWidget {
  final int mailboxId;
  const InboxScreen({super.key, required this.mailboxId});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider.notifier).fetchInbox(widget.mailboxId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final messages = state.inboxMessages;
    final unreadCount = state.inbox.where((m) => !m.isRead).length;

    return MailboxFolderScaffold(
      title: 'Inbox',
      activeRoute: AppRoutes.inbox(widget.mailboxId),
      messages: messages,
      mailboxId: widget.mailboxId,
      showFilters: true,
      unreadCount: unreadCount,
      showRiskBadge: false,
    );
  }
}
