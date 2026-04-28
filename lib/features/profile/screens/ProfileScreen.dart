// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/features/auth/providers/profile_provider.dart';

class Profilescreen extends ConsumerWidget {
  const Profilescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _buildAppBar(context),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(profileProvider.notifier).refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.screenVertical,
                ),
                child: Column(
                  children: [
                    // ── Avatar + Name ──────────────────────
                    _buildProfileHeader(context, profile),
                    const SizedBox(height: AppSpacing.x5),

                    // ── Edit Profile Button ────────────────
                    _buildEditProfileButton(context),
                    const SizedBox(height: AppSpacing.x8),

                    // ── Security & Privacy ─────────────────
                    _buildSectionLabel(context, 'SECURITY & PRIVACY'),
                    const SizedBox(height: AppSpacing.x2),
                    _buildSecuritySection(context, profile),
                    const SizedBox(height: AppSpacing.x6),

                    // ── Preferences ────────────────────────
                    _buildSectionLabel(context, 'PREFERENCES'),
                    const SizedBox(height: AppSpacing.x2),
                    _buildPreferencesSection(context, profile),
                    const SizedBox(height: AppSpacing.x8),

                    // ── Logout Button ──────────────────────
                    _buildLogoutButton(context, ref, state.isLoggingOut),
                    const SizedBox(height: AppSpacing.x8),
                  ],
                ),
              ),
            ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // AppBar
  // ══════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: context.bgColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20, color: context.text1),
        onPressed: () {
          if (context.canPop()) context.pop();
        },
      ),
      title: Text(
        'Profile',
        style: AppTextStyles.headingL.copyWith(color: context.text1),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, size: 22, color: context.text1),
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // Profile Header
  // ══════════════════════════════════════════════════════════

  Widget _buildProfileHeader(BuildContext context, UserProfile? profile) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.x4),
        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            // Green glow ring
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    context.button1,
                    context.button1.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // White separator ring
            Container(
              width: 102,
              height: 102,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.bgColor,
              ),
            ),
            // Avatar circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.card2,
                image: profile?.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(profile!.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: profile?.avatarUrl == null
                  ? Icon(Icons.person, size: 48, color: context.button1)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x4),

        // Name
        Text(
          profile?.username ?? '—',
          style: AppTextStyles.displayS.copyWith(
            color: context.text1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.x1),

        // Email
        Text(
          profile?.email ?? '—',
          style: AppTextStyles.bodyM.copyWith(color: context.button1),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // Edit Profile Button
  // ══════════════════════════════════════════════════════════

  Widget _buildEditProfileButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.buttonHeightL,
      child: ElevatedButton(
        onPressed: () => context.push(AppRoutes.editProfile),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        child: Text(
          'Edit Profile',
          style: AppTextStyles.labelL.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Section Label
  // ══════════════════════════════════════════════════════════

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: context.text3,
          letterSpacing: 1.5,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Security Section
  // ══════════════════════════════════════════════════════════

  Widget _buildSecuritySection(BuildContext context, UserProfile? profile) {
    return _buildCard(
      context: context,
      children: [
        _buildNavItem(
          context: context,
          icon: Icons.manage_accounts_outlined,
          title: 'Account Settings',
          subtitle: 'Personal info, primary email',
          onTap: () => context.push(AppRoutes.editProfile),
        ),
        _buildDivider(context),
        _buildNavItem(
          context: context,
          icon: Icons.lock_outlined,
          title: 'Security & Encryption',
          subtitle: '2FA, PGP keys, active sessions',
          trailing: profile?.twoFactorEnabled == true
              ? _buildBadge(context, '2FA ON', isGreen: true)
              : null,
          onTap: () => context.push(AppRoutes.twoFactorAuth),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // Preferences Section
  // ══════════════════════════════════════════════════════════

  Widget _buildPreferencesSection(BuildContext context, UserProfile? profile) {
    final storagePercent = profile?.storageUsedPercent ?? 85;

    return _buildCard(
      context: context,
      children: [
        _buildNavItem(
          context: context,
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Alerts, push sounds, quiet hours',
          onTap: () {},
        ),
        _buildDivider(context),
        _buildNavItem(
          context: context,
          icon: Icons.cloud_outlined,
          title: 'Vault Storage',
          subtitle: 'Manage encrypted file storage',
          trailing: _buildStorageBadge(context, storagePercent),
          onTap: () {},
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // Logout Button
  // ══════════════════════════════════════════════════════════

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoggingOut,
  ) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.buttonHeightL,
      child: OutlinedButton(
        onPressed: isLoggingOut
            ? null
            : () async {
                final confirmed = await _showLogoutDialog(context);
                if (confirmed != true) return;

                final success =
                    await ref.read(profileProvider.notifier).logout();

                if (success && context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE24B4A),
          side: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          minimumSize: Size.zero,
        ),
        child: isLoggingOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE24B4A),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFFE24B4A),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Text(
                    'Logout Securely',
                    style: AppTextStyles.labelL
                        .copyWith(color: const Color(0xFFE24B4A)),
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Reusable Widgets
  // ══════════════════════════════════════════════════════════

  Widget _buildCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            _buildIconBox(context, icon),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyM.copyWith(
                      color: context.text1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: context.text3),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: AppSpacing.x2),
            ],
            Icon(Icons.chevron_right, color: context.text3, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(BuildContext context, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.button1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Icon(icon, color: context.button1, size: 20),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: context.fieldBorder.withOpacity(0.3),
      height: 1,
      indent: AppSpacing.x4 + 40 + AppSpacing.x3,
    );
  }

  /// Green or teal small badge
  Widget _buildBadge(
    BuildContext context,
    String label, {
    bool isGreen = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: context.button1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: context.button1.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: context.button1,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Storage badge — changes color based on usage %
  Widget _buildStorageBadge(BuildContext context, int percent) {
    final Color color;
    if (percent >= 90) {
      color = const Color(0xFFE24B4A); // red
    } else if (percent >= 70) {
      color = const Color(0xFFE8A838); // amber
    } else {
      color = context.button1; // green
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$percent% FULL',
        style: AppTextStyles.labelS.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Logout Confirmation Dialog
  // ══════════════════════════════════════════════════════════

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.card1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          side: BorderSide(color: context.fieldBorder.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE24B4A),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.x3),
            Text(
              'Logout',
              style: AppTextStyles.headingM.copyWith(color: context.text1),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout securely from SecureMail?',
          style: AppTextStyles.bodyM.copyWith(color: context.text3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelM.copyWith(color: context.text3),
            ),
          ),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A),
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x5,
                vertical: AppSpacing.x2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            child: Text(
              'Logout',
              style: AppTextStyles.labelM.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
