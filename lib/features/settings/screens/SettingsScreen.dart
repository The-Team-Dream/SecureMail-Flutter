// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/sessions_provider.dart';
import 'package:securemail/features/profile/providers/profile_provider.dart';
import 'package:securemail/core/services/cache_service.dart';

class Settingsscreen extends ConsumerStatefulWidget {
  const Settingsscreen({super.key});

  @override
  ConsumerState<Settingsscreen> createState() => _SettingsscreenState();
}

class _SettingsscreenState extends ConsumerState<Settingsscreen> {
  // ✅ لا حاجة لـ _darkMode

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.isDark; // ← نستخدم الـ extension لمراقبة الحالة الفعلية
    ref.watch(
        themeProvider); // ← نحتاج مراقبة الـ provider ليعاد بناء الودجت عند التغيير

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.screenVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('PERSONAL'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Edit Profile',
                  subtitle: ref.watch(profileProvider).profile?.username ?? 'Update your name and photo',
                  onTap: () {
                    context.push(AppRoutes.editProfile);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Appearance ────────────────────────────────
            _buildSectionLabel('APPEARANCE'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildToggleItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Save battery and reduce strain',
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).toggleTheme(isDark);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Security ──────────────────────────────────
            _buildSectionLabel('SECURITY'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.key_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your security credentials',
                  onTap: () {
                    context.push(AppRoutes.changePassword);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Session Management ────────────────────────
            _buildSectionLabel('SESSION MANAGEMENT'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.devices_outlined,
                  title: 'Logged in Devices',
                  subtitle: '${ref.watch(sessionsProvider).sessions.length} active sessions detected',
                  onTap: () {
                    context.push(AppRoutes.loggedInDevices);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Preferences ───────────────────────────────
            _buildSectionLabel('PREFERENCES'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Push and Security alerts',
                  onTap: () {
                    context.push(AppRoutes.notificationsSettings);
                  },
                ),
                _buildDivider(),
                _buildNavItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Encryption and Biometrics',
                  onTap: () {
                    context.push(AppRoutes.privacySecurity);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Clear Cache ───────────────────────────────
            _buildClearCacheCard(),
            const SizedBox(height: AppSpacing.x6),

            // ── Footer ────────────────────────────────────
            _buildFooter(),
            const SizedBox(height: AppSpacing.x8),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelS.copyWith(
        color: context.text3,
        letterSpacing: 1.5,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withValues(alpha: 0.3)),
      ),
      child: Column(children: children),
    );
  }

  // ── Nav Item ──────────────────────────────────────────────
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyM.copyWith(
                          color: context.text1, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          AppTextStyles.bodyS.copyWith(color: context.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.text3, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Toggle Item ───────────────────────────────────────────
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          _buildIconBox(icon),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyM.copyWith(
                        color: context.text1, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: context.text3)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.button1,
            activeTrackColor: context.button1.withValues(alpha: 0.3),
            inactiveThumbColor: context.text3,
            inactiveTrackColor: context.card2,
          ),
        ],
      ),
    );
  }

  // ── Icon Box ──────────────────────────────────────────────
  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.button1.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Icon(icon, color: context.button1, size: 20),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Divider(
      color: context.fieldBorder.withValues(alpha: 0.3),
      height: 1,
      indent: AppSpacing.x4 + 40 + AppSpacing.x3,
    );
  }

  // ── Clear Cache Card ──────────────────────────────────────
  Widget _buildClearCacheCard() {
    final cacheSize = ref.watch(cacheSizeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.fieldBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE24B4A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.delete_outline,
                color: Color(0xFFE24B4A), size: 20),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clear Cache',
                    style: AppTextStyles.bodyM.copyWith(
                        color: const Color(0xFFE24B4A),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${cacheSize.toStringAsFixed(1)} MB of temporary data',
                    style: AppTextStyles.bodyS.copyWith(color: context.text3)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              await ref.read(cacheSizeProvider.notifier).clear();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE24B4A),
              side: const BorderSide(color: Color(0xFFE24B4A)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4, vertical: AppSpacing.x2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Clear',
                style: AppTextStyles.labelS
                    .copyWith(color: const Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        // Secure Protocol Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4, vertical: AppSpacing.x2),
            decoration: BoxDecoration(
              border: Border.all(color: context.button1.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: context.button1, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  'SECURE PROTOCOL V3.4 ACTIVE',
                  style: AppTextStyles.labelS.copyWith(
                    color: context.button1,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
