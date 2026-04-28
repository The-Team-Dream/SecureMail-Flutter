import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_folder_scaffold.dart';

class PhishingScreen extends StatelessWidget {
  const PhishingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MailboxFolderScaffold(
      title: 'Phishing',
      activeRoute: AppRoutes.phishing,
      messages: MailboxMockMessages.phishing,
    );
  }
}
