import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/widgets/reclassify_sheet.dart';

class MailboxMessageList extends StatelessWidget {
  const MailboxMessageList({
    super.key,
    required this.messages,
    required this.folderName,
    this.emptyTitle = 'No messages',
    this.showRiskBadge = true,
  });

  final List<MailboxMessage> messages;
  final String folderName;
  final String emptyTitle;
  final bool showRiskBadge;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            emptyTitle,
            style: AppTextStyles.bodyM.copyWith(color: context.text3),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return _MessageTile(
          message: messages[index],
          folderName: folderName,
          showRiskBadge: showRiskBadge,
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
          thickness: 1,
          color: context.text3.withValues(alpha: 0.15),
        );
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.folderName,
    this.showRiskBadge = true,
  });

  final MailboxMessage message;
  final String folderName;
  final bool showRiskBadge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        AppRoutes.messageDetail,
        extra: {'message': message, 'folder': folderName},
      ),
      onLongPress: folderName == 'Sent' ? null : () => _showReclassifySheet(context),
      child: Container(
        height: showRiskBadge ? 114 : 88,
        color: message.isActive ? context.card1 : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 2,
              color: message.isActive ? context.button1 : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
                child: Row(
                  children: [
                    _Avatar(
                      message: message,
                      showRiskBadge: showRiskBadge,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  message.sender,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyM.copyWith(
                                    color: context.text1,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                message.timeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: context.text3,
                                  fontSize: 11,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            message.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.text2,
                              fontSize: 13,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            message.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyS.copyWith(
                              color: context.text3,
                              fontSize: 12,
                              height: 1.15,
                            ),
                          ),
                          if (showRiskBadge) ...[
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: message.badgeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    message.badgeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelS.copyWith(
                                      color: message.badgeColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReclassifySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ReclassifySheet(
        message: message,
        currentFolder: folderName,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.message,
    this.showRiskBadge = true,
  });

  final MailboxMessage message;
  final bool showRiskBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: message.avatarColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        message.initials,
        style: AppTextStyles.headingM.copyWith(
          color: showRiskBadge && message.badgeColor == const Color(0xFFFF5252)
              ? const Color(0xFFFF5252)
              : context.button1,
          fontWeight: FontWeight.w800,
          fontSize: 16,
          height: 1,
        ),
      ),
    );
  }
}
