import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  String _selectedCategory = 'ALL';

  NotificationProvider() {
    _notifications = NotificationItem.sampleNotifications;
  }

  List<NotificationItem> get notifications {
    if (_selectedCategory == 'ALL') return List.unmodifiable(_notifications);
    if (_selectedCategory == 'MATCHES') {
      return _notifications
          .where(
            (n) =>
                n.type == NotificationType.newMatch ||
                n.type == NotificationType.newMessage,
          )
          .toList();
    }
    if (_selectedCategory == 'LIKES') {
      return _notifications
          .where((n) => n.type == NotificationType.likeReceived)
          .toList();
    }
    if (_selectedCategory == 'CAMPUS') {
      return _notifications
          .where(
            (n) =>
                n.type == NotificationType.campusEvent ||
                n.type == NotificationType.systemAlert,
          )
          .toList();
    }
    return List.unmodifiable(_notifications);
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}
