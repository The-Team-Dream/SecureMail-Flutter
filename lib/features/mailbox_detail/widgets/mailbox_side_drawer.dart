import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class MailboxSideDrawer extends StatelessWidget {
  const MailboxSideDrawer({
    super.key,
    required this.activeRoute,
    this.mailboxEmail = '',
    this.unreadCount,
  });

  final String activeRoute;
  final String mailboxEmail;
  final int? unreadCount;



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: width < 380 ? width * 0.88 : 320,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onClose: () => Navigator.of(context).pop(),
                mailboxEmail: mailboxEmail,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('FOLDERS'),
                      const SizedBox(height: 10),
                      _DrawerItem(
                        icon: Icons.inbox_rounded,
                        label: 'Inbox',
                        route: AppRoutes.inbox,
                        activeRoute: activeRoute,
                        count: unreadCount != null && unreadCount! > 0
                            ? unreadCount.toString()
                            : null,
                      ),
                      _DrawerItem(
                        icon: Icons.send_outlined,
                        label: 'Sent',
                        route: AppRoutes.sent,
                        activeRoute: activeRoute,
                      ),
                      _DrawerItem(
                        icon: Icons.report_gmailerrorred_outlined,
                        label: 'Spam',
                        route: AppRoutes.spam,
                        activeRoute: activeRoute,
                      ),
                      _DrawerItem(
                        icon: Icons.shield_outlined,
                        label: 'Malware',
                        route: AppRoutes.malware,
                        activeRoute: activeRoute,
                        alert: true,
                      ),
                      _DrawerItem(
                        icon: Icons.phishing_outlined,
                        label: 'Phishing',
                        route: AppRoutes.phishing,
                        activeRoute: activeRoute,
                      ),
                      const SizedBox(height: 26),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 24),
                      _SectionLabel('SYSTEM'),
                      const SizedBox(height: 10),
                      _DrawerItem(
                        icon: Icons.analytics_outlined,
                        label: 'Reports',
                        route: AppRoutes.reports,
                        activeRoute: activeRoute,
                      ),
                      _DrawerItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        route: AppRoutes.mailboxSettings,
                        activeRoute: activeRoute,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _StorageCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onClose,
    required this.mailboxEmail,
  });

  final VoidCallback onClose;
  final String mailboxEmail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.button1, width: 2),
            boxShadow: [
              BoxShadow(
                color: context.button1.withValues(alpha: 0.45),
                blurRadius: 10,
              ),
            ],
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mailboxEmail.isNotEmpty ? mailboxEmail : 'My Mailbox',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyL.copyWith(
                  color: context.text1,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          style: IconButton.styleFrom(
            backgroundColor: context.card1.withValues(alpha: 0.65),
            shape: const CircleBorder(),
          ),
          icon: Icon(
            Icons.close_rounded,
            color: context.button1,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelS.copyWith(
        color: context.text3,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.activeRoute,
    this.count,
    this.alert = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final String activeRoute;
  final String? count;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final selected = route == activeRoute;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          if (!selected) context.go(route);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                selected ? context.button1.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? context.button1
                    : context.text3,
                size: 21,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyM.copyWith(
                    color: selected
                        ? context.text1
                        : context.text3,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.button1,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    count!,
                    style: AppTextStyles.labelS.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (alert)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Encrypted Storage',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelS.copyWith(
                    color: context.text1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '75%',
                style: AppTextStyles.labelS.copyWith(
                  color: context.button1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: 0.75,
              backgroundColor: context.button1.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                context.button1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '15.0 GB / 20.0 GB USED',
            style: AppTextStyles.caption.copyWith(
              color: context.text3,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
