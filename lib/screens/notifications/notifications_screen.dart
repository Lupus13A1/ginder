import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
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
              decoration: const BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 3.0),
                ),
              ),
              child: Row(
                children: [
                  const GeometricBrandMark(size: 13, spacing: 5),
                  const SizedBox(width: 10),
                  Text(
                    'NOTIFICATIONS',
                    style: BauhausTextStyles.headlineMedium().copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  if (notifProvider.unreadCount > 0)
                    GestureDetector(
                      onTap: () => notifProvider.markAllAsRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BauhausColors.cardYellow,
                          border: Border.all(
                            color: BauhausColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'MARK READ',
                          style: BauhausTextStyles.badge(
                            color: BauhausColors.foreground,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Category Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: BauhausColors.surface,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = notifProvider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => notifProvider.setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BauhausColors.primaryRed
                              : BauhausColors.background,
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: BauhausColors.border,
                            width: 2.0,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: BauhausColors.border,
                                    offset: Offset(2, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: BauhausTextStyles.badge(
                            color: isSelected
                                ? Colors.white
                                : BauhausColors.foreground,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(
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
          color: item.isRead ? BauhausColors.surface : BauhausColors.cardYellow,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: BauhausColors.border,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Geometric category box icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.categoryColor,
                  border: Border.all(color: BauhausColors.border, width: 2.0),
                ),
                child: Icon(
                  item.iconData,
                  size: 20,
                  color:
                      item.categoryColor == BauhausColors.cardYellow ||
                          item.categoryColor == BauhausColors.primaryYellow
                      ? BauhausColors.foreground
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title.toUpperCase(),
                            style: BauhausTextStyles.title().copyWith(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: BauhausColors.primaryRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BauhausColors.border,
                                width: 1.0,
                              ),
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
