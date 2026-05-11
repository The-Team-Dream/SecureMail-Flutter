import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class SentScreen extends ConsumerStatefulWidget {
  final int mailboxId;
  const SentScreen({super.key, required this.mailboxId});

  @override
  ConsumerState<SentScreen> createState() => _SentScreenState();
}

class _SentScreenState extends ConsumerState<SentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider.notifier).fetchSent(widget.mailboxId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final messages = state.sentMessages;

    return MailboxFolderScaffold(
      title: 'Sent',
      activeRoute: AppRoutes.sent(widget.mailboxId),
      messages: messages,
      mailboxId: widget.mailboxId,
      onRefresh: () => ref.read(messagesProvider.notifier).fetchSent(widget.mailboxId, refresh: true),
    );
  }
}
