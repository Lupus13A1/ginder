import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    final categories = ['ALL', 'MATCHES', 'LIKES', 'CAMPUS'];

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: BauhausTextStyles.headlineMedium().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (notifProvider.unreadCount > 0)
                    GestureDetector(
                      onTap: () => notifProvider.markAllAsRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: BauhausColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: BauhausColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          'Mark Read',
                          style: BauhausTextStyles.badge(
                            color: BauhausColors.foreground,
                          ).copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Category Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: BauhausColors.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = notifProvider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => notifProvider.setCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? BauhausColors.primaryBlue
                                : BauhausColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? BauhausColors.primaryBlue
                                  : BauhausColors.border,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: BauhausTextStyles.badge(
                              color: isSelected
                                  ? Colors.white
                                  : BauhausColors.foreground,
                            ).copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Divider(
              thickness: 2.0,
              color: BauhausColors.border,
              height: 2,
            ),

            // Notification Feed
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No campus notifications in this category.',
                        style: BauhausTextStyles.bodyMedium(),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return _buildNotificationCard(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    final notifProvider = context.read<NotificationProvider>();

    return GestureDetector(
      onTap: () => notifProvider.markAsRead(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? BauhausColors.border
                : item.categoryColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isRead
                  ? Colors.black.withValues(alpha: 0.02)
                  : item.categoryColor.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.iconData, size: 22, color: item.categoryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: BauhausTextStyles.title().copyWith(
                              fontSize: 14,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: item.categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: BauhausTextStyles.bodyMedium(
                        color: Colors.grey.shade800,
                      ).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(item.timestamp),
                      style: BauhausTextStyles.caption(
                        color: Colors.grey.shade600,
                      ).copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} MIN AGO';
    if (diff.inHours < 24) return '${diff.inHours} HOURS AGO';
    return '${diff.inDays} DAYS AGO';
  }
}
