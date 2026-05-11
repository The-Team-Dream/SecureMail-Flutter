import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/widgets/reclassify_sheet.dart';

class MailboxMessageList extends StatefulWidget {
  const MailboxMessageList({
    super.key,
    required this.messages,
    required this.folderName,
    required this.mailboxId,
    this.emptyTitle = 'No messages',
    this.showRiskBadge = true,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  final List<MailboxMessage> messages;
  final String folderName;
  final int mailboxId;
  final String emptyTitle;
  final bool showRiskBadge;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

  @override
  State<MailboxMessageList> createState() => _MailboxMessageListState();
}

class _MailboxMessageListState extends State<MailboxMessageList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (widget.onLoadMore != null && !widget.isLoadingMore) {
        widget.onLoadMore!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            widget.emptyTitle,
            style: AppTextStyles.bodyM.copyWith(color: context.text3),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: widget.messages.length + (widget.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.messages.length) {
          return _MessageTile(
            message: widget.messages[index],
            folderName: widget.folderName,
            mailboxId: widget.mailboxId,
            showRiskBadge: widget.showRiskBadge,
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
      },
      separatorBuilder: (context, index) {
        if (index < widget.messages.length - 1 || widget.isLoadingMore) {
           return Divider(
            height: 1,
            thickness: 1,
            color: context.text3.withValues(alpha: 0.15),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.folderName,
    required this.mailboxId,
    this.showRiskBadge = true,
  });

  final MailboxMessage message;
  final String folderName;
  final int mailboxId;
  final bool showRiskBadge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        AppRoutes.messageDetail(mailboxId),
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
