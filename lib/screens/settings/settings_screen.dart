import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_dialog.dart';
import '../../widgets/bauhaus_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context) {
    BauhausDialog.show(
      context: context,
      title: 'LOG OUT OF CAMPUS?',
      content: const Text(
        'You will need to re-authenticate with your university credentials to log back in.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      primaryActionText: 'LOG OUT',
      onPrimaryAction: () {
        context.read<AuthProvider>().logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      },
      secondaryActionText: 'CANCEL',
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: const BauhausAppBar(title: 'APP SETTINGS', showBrandMark: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Discovery Preferences Card
          BauhausCard(
            borderWidth: 3.0,
            shadowOffset: 5.0,
            cornerBadge: BauhausCornerBadgeType.circleRed,
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
                      'DISCOVERY PREFERENCES',
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Max Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MAXIMUM DISTANCE', style: BauhausTextStyles.badge()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BauhausColors.cardYellow,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${auth.maxDistanceKm.toStringAsFixed(1)} KM',
                        style: BauhausTextStyles.badge(),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: BauhausColors.primaryRed,
                    inactiveTrackColor: BauhausColors.muted,
                    thumbColor: BauhausColors.foreground,
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: auth.maxDistanceKm,
                    min: 0.5,
                    max: 20.0,
                    divisions: 39,
                    onChanged: (v) => auth.updateSettings(maxDistanceKm: v),
                  ),
                ),

                const SizedBox(height: 10),

                // Age Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STUDENT AGE RANGE', style: BauhausTextStyles.badge()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BauhausColors.cardYellow,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${auth.ageRange.start.round()} - ${auth.ageRange.end.round()} YRS',
                        style: BauhausTextStyles.badge(),
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

          // 2. Privacy & Campus Visibility
          BauhausCard(
            borderWidth: 3.0,
            shadowOffset: 5.0,
            cornerBadge: BauhausCornerBadgeType.squareBlue,
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
                      'PRIVACY & VISIBILITY',
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'CAMPUS INCOGNITO MODE',
                    style: BauhausTextStyles.badge(),
                  ),
                  subtitle: Text(
                    'Hide profile from Discover browsing',
                    style: BauhausTextStyles.caption(),
                  ),
                  activeTrackColor: BauhausColors.primaryRed,
                  activeThumbColor: Colors.white,
                  value: auth.incognitoMode,
                  onChanged: (v) => auth.updateSettings(incognitoMode: v),
                ),
                const Divider(thickness: 1.5, color: BauhausColors.border),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'SHOW ONLINE ACTIVITY',
                    style: BauhausTextStyles.badge(),
                  ),
                  subtitle: Text(
                    'Display active green indicator in chats',
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

          // 3. Notification Preferences
          BauhausCard(
            borderWidth: 3.0,
            shadowOffset: 5.0,
            cornerBadge: BauhausCornerBadgeType.triangleYellow,
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
                      'NOTIFICATIONS',
                      style: BauhausTextStyles.title().copyWith(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'NEW MATCH ALERTS',
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryRed,
                  activeThumbColor: Colors.white,
                  value: auth.notifyNewMatches,
                  onChanged: (v) => auth.updateSettings(notifyNewMatches: v),
                ),
                const Divider(thickness: 1.5, color: BauhausColors.border),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'NEW CHAT MESSAGES',
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryBlue,
                  activeThumbColor: Colors.white,
                  value: auth.notifyMessages,
                  onChanged: (v) => auth.updateSettings(notifyMessages: v),
                ),
                const Divider(thickness: 1.5, color: BauhausColors.border),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'PROFILE LIKES & ACTIVITY',
                    style: BauhausTextStyles.badge(),
                  ),
                  activeTrackColor: BauhausColors.primaryYellow,
                  activeThumbColor: BauhausColors.foreground,
                  value: auth.notifyLikes,
                  onChanged: (v) => auth.updateSettings(notifyLikes: v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Log Out & Danger Zone
          BauhausButton.outline(
            text: 'LOG OUT OF GINDER',
            isFullWidth: true,
            height: 48,
            icon: const Icon(Icons.logout, size: 16),
            onPressed: () => _confirmLogout(context),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Account deletion requests are processed via student registrar.',
                  ),
                  backgroundColor: BauhausColors.foreground,
                ),
              );
            },
            child: Text(
              'DELETE STUDENT ACCOUNT',
              style: BauhausTextStyles.badge(
                color: Colors.red.shade800,
              ).copyWith(fontSize: 11),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
