import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/core/mock/mock_data.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final to = _toController.text.trim();
    if (to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a recipient',
              style: AppTextStyles.bodyS.copyWith(color: Colors.white)),
          backgroundColor: const Color(0xFFFF5252),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Simulate API request to backend to send and save the message
      await MockData.simulate(true, milliseconds: 1200);

      final msg = MailboxMessage(
        initials: to[0].toUpperCase(),
        sender: 'To: $to',
        subject: _subjectController.text.trim().isNotEmpty
            ? _subjectController.text.trim()
            : '(No Subject)',
        preview: _messageController.text.trim(),
        timeLabel: 'Just now',
        badgeLabel: 'SIGNED AND SENT',
        badgeColor: const Color(0xFF8CEB2F),
      );

      // Add to our mock list so the Sent screen shows it
      MailboxMockMessages.sent.insert(0, msg);

      if (mounted) {
        context.go('/mailboxes/sent');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close_rounded, color: context.text1),
        ),
        title: Text(
          'Compose',
          style: AppTextStyles.headingL.copyWith(color: context.text1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              onPressed: _isSending ? null : _sendMessage,
              style: IconButton.styleFrom(backgroundColor: context.button1),
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ComposeField(
            label: 'To:',
            hint: 'recipient@domain.com',
            controller: _toController,
          ),
          const SizedBox(height: 12),
          _ComposeField(
            label: 'Subject',
            hint: 'Secure subject',
            controller: _subjectController,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 260),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: context.fieldBg,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: context.button1.withValues(alpha: 0.35)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                style: AppTextStyles.bodyM.copyWith(color: context.text1),
                decoration: InputDecoration(
                  hintText: 'Write message...',
                  hintStyle: AppTextStyles.bodyM.copyWith(color: context.text3),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: context.fieldBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.button1.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: context.text1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyM.copyWith(color: context.text3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
