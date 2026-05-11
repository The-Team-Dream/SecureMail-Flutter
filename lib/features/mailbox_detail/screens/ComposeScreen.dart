import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/core/mock/mock_data.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({
    super.key, 
    this.initialRecipient, 
    this.initialSubject,
    this.mailboxId, // معرف الصندوق المطلوب الإرسال منه
  });

  final String? initialRecipient;
  final String? initialSubject;
  final int? mailboxId;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  List<File> _attachments = [];

  bool _isSending = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.where((path) => path != null).map((path) => File(path!)));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipient != null) {
      _toController.text = widget.initialRecipient!;
    }
    if (widget.initialSubject != null) {
      _subjectController.text = widget.initialSubject!;
    }
  }

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

    // نحتاج لمعرف الصندوق، إذا لم يتوفر نأخذ أول صندوق متاح (أو نظهر خطأ)
    final mbId = widget.mailboxId ?? 1; // الافتراضي 1 للتجربة، يفضل تمريره من الشاشة السابقة

    setState(() => _isSending = true);

    try {
      final success = await ref.read(messagesProvider.notifier).sendEmail(
        mailboxId: mbId,
        to:        to,
        subject:   _subjectController.text.trim().isNotEmpty
            ? _subjectController.text.trim()
            : '(No Subject)',
        bodyText:  _messageController.text.trim(),
        attachments: _attachments.isEmpty ? null : _attachments,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent successfully')),
        );
        context.go('/mailboxes/$mbId/sent'); // العودة لصفحة المرسل للصندوق الحالي
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Color(0xFFFF5252),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
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
          IconButton(
            onPressed: _pickFiles,
            icon: Icon(Icons.attach_file_rounded, color: context.text1),
          ),
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
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_attachments.length, (index) {
                final file = _attachments[index];
                final fileName = file.path.split(Platform.pathSeparator).last;
                return Chip(
                  label: Text(fileName, style: AppTextStyles.labelS.copyWith(color: context.text1)),
                  backgroundColor: context.fieldBg,
                  deleteIcon: Icon(Icons.close, size: 16, color: context.text1),
                  onDeleted: () => _removeAttachment(index),
                  side: BorderSide(color: context.button1.withValues(alpha: 0.35)),
                );
              }),
            ),
          ],
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
