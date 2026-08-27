import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/bauhaus_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import 'discover/discover_screen.dart';
import 'explore/explore_screen.dart';
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

  final List<Widget> _screens = const [
    DiscoverScreen(),
    ExploreScreen(),
    MatchesScreen(),
    NotificationsScreen(),
    MyProfileScreen(),
  ];

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
    final unreadChats = context.watch<ChatProvider>().totalUnreadCount;
    final unreadNotifs = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: BauhausColors.surface,
          border: Border(
            top: BorderSide(color: BauhausColors.border, width: 3.0),
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
                  icon: Icons.explore,
                  label: 'EXPLORE',
                  activeColor: BauhausColors.primaryBlue,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.chat_bubble,
                  label: 'MATCHES',
                  activeColor: BauhausColors.primaryYellow,
                  badgeCount: unreadChats,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.notifications,
                  label: 'ALERTS',
                  activeColor: BauhausColors.primaryRed,
                  badgeCount: unreadNotifs,
                ),
                _buildNavItem(
                  index: 4,
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
    final isYellow = activeColor == BauhausColors.primaryYellow;
    final activeTextColor = isYellow ? BauhausColors.foreground : Colors.white;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.zero,
            border: isSelected
                ? Border.all(color: BauhausColors.border, width: 2.0)
                : null,
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: BauhausColors.border,
                      offset: Offset(2, 2),
                    ),
                  ]
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
                    size: 20,
                    color: isSelected
                        ? activeTextColor
                        : BauhausColors.foreground,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isSelected
                          ? activeTextColor
                          : BauhausColors.foreground,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 2,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color:
                          isSelected && activeColor == BauhausColors.primaryRed
                          ? BauhausColors.primaryYellow
                          : BauhausColors.primaryRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          color:
                              isSelected &&
                                  activeColor == BauhausColors.primaryRed
                              ? BauhausColors.foreground
                              : Colors.white,
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
