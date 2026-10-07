import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_dialog.dart';
import '../../widgets/bauhaus_app_bar.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context, AppConfigProvider appConfig) {
    BauhausDialog.show(
      context: context,
      title: appConfig.tr('LOG OUT OF CAMPUS?', 'ออกจากระบบใช่หรือไม่?'),
      content: Text(
        appConfig.tr(
          'You will need to re-authenticate with your university credentials to log back in.',
          'คุณจะต้องเข้าสู่ระบบใหม่ด้วยอีเมลมหาวิทยาลัยเพื่อใช้งานอีกครั้ง',
        ),
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      primaryActionText: appConfig.tr('LOG OUT', 'ออกจากระบบ'),
      onPrimaryAction: () {
        context.read<AuthProvider>().logout();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      },
      secondaryActionText: appConfig.tr('CANCEL', 'ยกเลิก'),
    );
  }

  void _confirmDeleteAccount(
    BuildContext context,
    AppConfigProvider appConfig,
  ) {
    BauhausDialog.show(
      context: context,
      title: appConfig.tr('DELETE ACCOUNT?', 'ลบบัญชีผู้ใช้ถาวร?'),
      content: Text(
        appConfig.tr(
          'This action is permanent and cannot be undone. All your matches and messages will be lost.',
          'การกระทำนี้ไม่สามารถยกเลิกได้ ประวัติการแชทและการแมตช์ทั้งหมดของคุณจะถูกลบถาวร',
        ),
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      primaryActionText: appConfig.tr('DELETE', 'ลบบัญชี'),
      onPrimaryAction: () async {
        try {
          await context.read<AuthProvider>().deleteAccount();
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          }
        } catch (e) {
          if (context.mounted) {
            BauhausSnackBar.showError(context, e.toString());
          }
        }
      },
      secondaryActionText: appConfig.tr('CANCEL', 'ยกเลิก'),
    );
  }

  Widget _buildSegmentPill({
    required String text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? BauhausColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : BauhausColors.foreground,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : BauhausColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appConfig = context.watch<AppConfigProvider>();

    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: BauhausAppBar(
        title: appConfig.tr('APP SETTINGS', 'การตั้งค่าแอปพลิเคชัน'),
        showBrandMark: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 0. Account & Edit Profile Card
          BauhausCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                        color: BauhausColors.cardYellow,
                      ),
                      child: auth.currentUser.photos.isNotEmpty
                          ? Image.network(
                              auth.currentUser.photos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 26),
                            )
                          : const Icon(Icons.person, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser.name.toUpperCase(),
                            style: BauhausTextStyles.title().copyWith(
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.currentUser.studentEmail,
                            style: BauhausTextStyles.caption(
                              color: BauhausColors.isDark
                                  ? const Color(0xFF94A3B8)
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                BauhausButton(
                  text: appConfig.tr(
                    'EDIT CAMPUS PROFILE',
                    'แก้ไขโปรไฟล์นักศึกษา',
                  ),
                  isFullWidth: true,
                  height: 46,
                  variant: BauhausButtonVariant.primaryBlue,
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.editProfile);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 1. Appearance & Language Card (Theme + Language)
          BauhausCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.palette,
                      size: 18,
                      color: BauhausColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appConfig.tr('APPEARANCE & LANGUAGE', 'รูปแบบและภาษา'),
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Theme Mode Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appConfig.tr('THEME MODE', 'โหมดการแสดงผล'),
                      style: BauhausTextStyles.badge(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: BauhausColors.muted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSegmentPill(
                            text: appConfig.tr('LIGHT', 'สว่าง'),
                            icon: Icons.light_mode_outlined,
                            isSelected: appConfig.themeMode == ThemeMode.light,
                            onTap: () =>
                                appConfig.setThemeMode(ThemeMode.light),
                          ),
                          _buildSegmentPill(
                            text: appConfig.tr('DARK', 'มืด'),
                            icon: Icons.dark_mode_outlined,
                            isSelected: appConfig.themeMode == ThemeMode.dark,
                            onTap: () => appConfig.setThemeMode(ThemeMode.dark),
                          ),
                          _buildSegmentPill(
                            text: appConfig.tr('SYSTEM', 'ระบบ'),
                            icon: Icons.settings_brightness_outlined,
                            isSelected: appConfig.themeMode == ThemeMode.system,
                            onTap: () =>
                                appConfig.setThemeMode(ThemeMode.system),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(thickness: 1.0, color: BauhausColors.borderSubtle),
                const SizedBox(height: 10),

                // Language Selector (Strictly TH and EN)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appConfig.tr('LANGUAGE', 'ภาษา'),
                      style: BauhausTextStyles.badge(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: BauhausColors.muted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSegmentPill(
                            text: 'EN',
                            isSelected: !appConfig.isThai,
                            onTap: () => appConfig.setLanguage('en'),
                          ),
                          _buildSegmentPill(
                            text: 'TH',
                            isSelected: appConfig.isThai,
                            onTap: () => appConfig.setLanguage('th'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Discovery Preferences Card
          BauhausCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.explore,
                      size: 18,
                      color: BauhausColors.primaryRed,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appConfig.tr(
                        'DISCOVERY PREFERENCES',
                        'การค้นหาและจับคู่',
                      ),
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Age Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appConfig.tr('STUDENT AGE RANGE', 'ช่วงอายุนักศึกษา'),
                      style: BauhausTextStyles.badge(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BauhausColors.cardYellow,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '${auth.ageRange.start.round()} - ${auth.ageRange.end.round()} ${appConfig.tr('YRS', 'ปี')}',
                        style: BauhausTextStyles.badge().copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: auth.ageRange,
                  min: 18,
                  max: 30,
                  divisions: 12,
                  activeColor: BauhausColors.primaryBlue,
                  inactiveColor: BauhausColors.muted,
                  onChanged: (v) => auth.updateSettings(ageRange: v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Privacy & Campus Visibility
          BauhausCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.security,
                      size: 18,
                      color: BauhausColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appConfig.tr(
                        'PRIVACY & VISIBILITY',
                        'ความเป็นส่วนตัวและการมองเห็น',
                      ),
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appConfig.tr(
                      'CAMPUS INCOGNITO MODE',
                      'โหมดซ่อนตัว (INCOGNITO)',
                    ),
                    style: BauhausTextStyles.badge(),
                  ),
                  subtitle: Text(
                    appConfig.tr(
                      'Hide profile from Discover browsing',
                      'ซ่อนโปรไฟล์จากการค้นหาใน Discover',
                    ),
                    style: BauhausTextStyles.caption(),
                  ),
                  activeTrackColor: BauhausColors.primaryRed,
                  activeThumbColor: Colors.white,
                  value: auth.incognitoMode,
                  onChanged: (v) => auth.updateSettings(incognitoMode: v),
                ),
                Divider(thickness: 1.0, color: BauhausColors.borderSubtle),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appConfig.tr('SHOW ONLINE ACTIVITY', 'แสดงสถานะออนไลน์'),
                    style: BauhausTextStyles.badge(),
                  ),
                  subtitle: Text(
                    appConfig.tr(
                      'Display active green indicator in chats',
                      'แสดงจุดสีเขียวบอกสถานะออนไลน์ในห้องแชท',
                    ),
                    style: BauhausTextStyles.caption(),
                  ),
                  activeTrackColor: BauhausColors.primaryBlue,
                  activeThumbColor: Colors.white,
                  value: auth.showOnlineStatus,
                  onChanged: (v) => auth.updateSettings(showOnlineStatus: v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Notification Preferences
          BauhausCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications,
                      size: 18,
                      color: BauhausColors.primaryYellow,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      appConfig.tr('NOTIFICATIONS', 'การแจ้งเตือน'),
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appConfig.tr('NEW MATCH ALERTS', 'แจ้งเตือนเมื่อแมตช์ใหม่'),
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryRed,
                  activeThumbColor: Colors.white,
                  value: auth.notifyNewMatches,
                  onChanged: (v) => auth.updateSettings(notifyNewMatches: v),
                ),
                Divider(thickness: 1.0, color: BauhausColors.borderSubtle),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appConfig.tr('NEW CHAT MESSAGES', 'แจ้งเตือนข้อความแชท'),
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryBlue,
                  activeThumbColor: Colors.white,
                  value: auth.notifyMessages,
                  onChanged: (v) => auth.updateSettings(notifyMessages: v),
                ),
                Divider(thickness: 1.0, color: BauhausColors.borderSubtle),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    appConfig.tr(
                      'PROFILE LIKES & ACTIVITY',
                      'แจ้งเตือนการกดไลก์และกิจกรรม',
                    ),
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryYellow,
                  activeThumbColor: Colors.white,
                  value: auth.notifyLikes,
                  onChanged: (v) => auth.updateSettings(notifyLikes: v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Log Out & Danger Zone
          BauhausButton.outline(
            text: appConfig.tr('LOG OUT OF GINDER', 'ออกจากระบบ GINDER'),
            isFullWidth: true,
            height: 48,
            icon: const Icon(Icons.logout, size: 16),
            onPressed: () => _confirmLogout(context, appConfig),
          ),

          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () => _confirmDeleteAccount(context, appConfig),
              child: Text(
                appConfig.tr('DELETE STUDENT ACCOUNT', 'ลบบัญชีนักศึกษาถาวร'),
                style: BauhausTextStyles.badge(
                  color: Colors.red.shade700,
                ).copyWith(fontSize: 11),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
