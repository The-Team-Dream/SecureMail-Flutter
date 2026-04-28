import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class ComposeScreen extends StatelessWidget {
  const ComposeScreen({super.key});



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
              onPressed: () {},
              style: IconButton.styleFrom(backgroundColor: context.button1),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ComposeField(label: 'To', hint: 'recipient@domain.com'),
          const SizedBox(height: 12),
          _ComposeField(label: 'Subject', hint: 'Secure subject'),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 260),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.card1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.button1.withValues(alpha: 0.35)),
              ),
              child: TextField(
                maxLines: null,
                style: AppTextStyles.bodyM.copyWith(color: context.text1),
                decoration: InputDecoration(
                  hintText: 'Write encrypted message...',
                  hintStyle: AppTextStyles.bodyM.copyWith(color: context.text3),
                  border: InputBorder.none,
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
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: context.button1.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: context.text3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    AppTextStyles.bodyM.copyWith(color: context.text3),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
