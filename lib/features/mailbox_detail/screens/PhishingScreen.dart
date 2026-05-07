import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class PhishingScreen extends ConsumerStatefulWidget {
  final int mailboxId;
  const PhishingScreen({super.key, required this.mailboxId});

  @override
  ConsumerState<PhishingScreen> createState() => _PhishingScreenState();
}

class _PhishingScreenState extends ConsumerState<PhishingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(messagesProvider.notifier).fetchPhishing(widget.mailboxId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final messages = state.phishingMessages;

    return MailboxFolderScaffold(
      title: 'Phishing',
      activeRoute: AppRoutes.phishing(widget.mailboxId),
      messages: messages,
      mailboxId: widget.mailboxId,
    );
  }
}
