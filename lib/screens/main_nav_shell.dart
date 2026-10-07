import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/bauhaus_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/app_config_provider.dart';
import 'discover/discover_screen.dart';
import 'matches/matches_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/my_profile_screen.dart';

class MainNavShell extends StatefulWidget {
  final int initialIndex;

  const MainNavShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavShell> createState() => _MainNavShellState();
}

class _MainNavShellState extends State<MainNavShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.watch<AppConfigProvider>();
    final unreadChats = context.watch<ChatProvider>().totalUnreadCount;
    final unreadNotifs = context.watch<NotificationProvider>().unreadCount;

    final screens = [
      DiscoverScreen(key: ValueKey('discover_${appConfig.isDark}')),
      MatchesScreen(key: ValueKey('matches_${appConfig.isDark}')),
      NotificationsScreen(key: ValueKey('notifs_${appConfig.isDark}')),
      MyProfileScreen(key: ValueKey('profile_${appConfig.isDark}')),
    ];

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          border: Border(
            top: BorderSide(color: BauhausColors.border, width: 1.0),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.style,
                  label: 'DISCOVER',
                  activeColor: BauhausColors.primaryRed,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.chat_bubble,
                  label: 'MATCHES',
                  activeColor: BauhausColors.primaryYellow,
                  badgeCount: unreadChats,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.notifications,
                  label: 'ALERTS',
                  activeColor: BauhausColors.primaryRed,
                  badgeCount: unreadNotifs,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person,
                  label: 'PROFILE',
                  activeColor: BauhausColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    final tabActiveColor = activeColor == BauhausColors.primaryYellow
        ? const Color(0xFFD97706)
        : activeColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? tabActiveColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: tabActiveColor.withValues(alpha: 0.28),
                    width: 1.0,
                  )
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 21,
                    color: isSelected
                        ? tabActiveColor
                        : BauhausColors.textMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? tabActiveColor
                          : BauhausColors.textMuted,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 2,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryRed,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
