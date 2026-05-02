import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class SentScreen extends StatelessWidget {
  const SentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MailboxFolderScaffold(
      title: 'Sent',
      activeRoute: AppRoutes.sent,
      messages: MailboxMockMessages.sent,
    );
  }
}
