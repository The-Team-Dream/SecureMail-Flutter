import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_message_list.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_side_drawer.dart';

class MailboxFolderScaffold extends StatefulWidget {
  const MailboxFolderScaffold({
    super.key,
    required this.title,
    required this.activeRoute,
    required this.messages,
    this.showFilters = false,
    this.trailing,
    this.mailboxEmail = '',
    this.unreadCount,
  });

  final String title;
  final String activeRoute;
  final List<MailboxMessage> messages;
  final bool showFilters;
  final Widget? trailing;
  final String mailboxEmail;
  final int? unreadCount;

  @override
  State<MailboxFolderScaffold> createState() => _MailboxFolderScaffoldState();
}

class _MailboxFolderScaffoldState extends State<MailboxFolderScaffold> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';
  String _query = '';



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _filteredMessages;

    return Scaffold(
      backgroundColor: context.bgColor,
      drawer: MailboxSideDrawer(
        activeRoute: widget.activeRoute,
        mailboxEmail: widget.mailboxEmail,
        unreadCount: widget.unreadCount,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.compose),
        backgroundColor: context.button1,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_outlined),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: context.barBg,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                    child: Row(
                      children: [
                        Builder(
                          builder: (scaffoldContext) {
                            return IconButton(
                              onPressed: () =>
                                  Scaffold.of(scaffoldContext).openDrawer(),
                              icon: Icon(
                                Icons.menu_rounded,
                                color: context.text1,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(40, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.title,
                          style: AppTextStyles.displayS.copyWith(
                            color: context.text1,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SearchField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _query = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        widget.trailing ?? const _ProfileAvatar(),
                      ],
                    ),
                  ),
                  if (widget.showFilters)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _activeFilter == 'All',
                            onTap: () => _setFilter('All'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Unread',
                            selected: _activeFilter == 'Unread',
                            onTap: () => _setFilter('Unread'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Secure',
                            selected: _activeFilter == 'Secure',
                            onTap: () => _setFilter('Secure'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Flagged',
                            selected: _activeFilter == 'Flagged',
                            onTap: () => _setFilter('Flagged'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: MailboxMessageList(
                messages: messages,
                emptyTitle: 'No ${widget.title.toLowerCase()} messages',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MailboxMessage> get _filteredMessages {
    var messages = widget.messages;

    if (_query.trim().isNotEmpty) {
      final query = _query.trim().toLowerCase();
      messages = messages.where((message) {
        return message.sender.toLowerCase().contains(query) ||
            message.subject.toLowerCase().contains(query) ||
            message.preview.toLowerCase().contains(query) ||
            message.badgeLabel.toLowerCase().contains(query);
      }).toList();
    }

    if (!widget.showFilters || _activeFilter == 'All') return messages;

    return messages.where((message) {
      switch (_activeFilter) {
        case 'Unread':
          return message.isActive;
        case 'Secure':
          return message.badgeLabel.contains('ENCRYPTED') ||
              message.badgeLabel.contains('VERIFIED');
        case 'Flagged':
          return message.badgeColor == const Color(0xFFFF5252) ||
              message.badgeLabel.contains('RISK');
        default:
          return true;
      }
    }).toList();
  }

  void _setFilter(String value) {
    setState(() => _activeFilter = value);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 40),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyM.copyWith(
          color: context.text1,
          height: 1,
        ),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: AppTextStyles.bodyM.copyWith(
            color: context.text3,
            height: 1,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.text3,
            size: 20,
          ),
          filled: true,
          fillColor: context.fieldBg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(
              color: context.button1,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? context.button1
                : context.button1
                    .withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: context.button1.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelS.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.profile),
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFD9FFF4),
          shape: BoxShape.circle,
          border: Border.all(
            color: context.button1,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person,
              color: context.button1,
            ),
          ),
        ),
      ),
    );
  }
}
