import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class SpamScreen extends ConsumerWidget {
  const SpamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider).spam;

    return MailboxFolderScaffold(
      title: 'Spam',
      activeRoute: AppRoutes.spam,
      messages: messages,
    );
  }
}
