import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class SpamScreen extends StatelessWidget {
  const SpamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MailboxFolderScaffold(
      title: 'Spam',
      activeRoute: AppRoutes.spam,
      messages: MailboxMockMessages.spam,
    );
  }
}
