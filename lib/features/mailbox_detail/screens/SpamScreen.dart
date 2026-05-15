import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class SpamScreen extends ConsumerStatefulWidget {
  final int mailboxId;
  const SpamScreen({super.key, required this.mailboxId});

  @override
  ConsumerState<SpamScreen> createState() => _SpamScreenState();
}

class _SpamScreenState extends ConsumerState<SpamScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider.notifier).fetchSpam(widget.mailboxId);
    });
  }

  @override
  void didUpdateWidget(covariant SpamScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mailboxId != widget.mailboxId) {
      Future.microtask(() {
        ref.read(messagesProvider.notifier).fetchSpam(widget.mailboxId, refresh: true);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final messages = state.spamMessages;

    return MailboxFolderScaffold(
      title: 'Spam',
      activeRoute: AppRoutes.spam(widget.mailboxId),
      messages: messages,
      mailboxId: widget.mailboxId,
      onRefresh: () => ref.read(messagesProvider.notifier).fetchSpam(widget.mailboxId, refresh: true),
    );
  }
}
