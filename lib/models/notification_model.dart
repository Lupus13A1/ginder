import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';

enum NotificationType {
  newMatch,
  likeReceived,
  newMessage,
  campusEvent,
  systemAlert,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? peerAvatar;
  final String? actionRoute;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.peerAvatar,
    this.actionRoute,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? peerAvatar,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  Color get categoryColor {
    switch (type) {
      case NotificationType.newMatch:
        return BauhausColors.primaryRed;
      case NotificationType.newMessage:
        return BauhausColors.primaryBlue;
      case NotificationType.likeReceived:
        return BauhausColors.primaryYellow;
      case NotificationType.campusEvent:
        return BauhausColors.cardYellow;
      case NotificationType.systemAlert:
        return BauhausColors.foreground;
    }
  }

  IconData get iconData {
    switch (type) {
      case NotificationType.newMatch:
        return Icons.favorite;
      case NotificationType.newMessage:
        return Icons.chat_bubble;
      case NotificationType.likeReceived:
        return Icons.thumb_up_alt;
      case NotificationType.campusEvent:
        return Icons.campaign;
      case NotificationType.systemAlert:
        return Icons.verified_user;
    }
  }

  static List<NotificationItem> get sampleNotifications => [
    NotificationItem(
      id: 'notif_1',
      type: NotificationType.newMatch,
      title: "IT'S A NEW MATCH!",
      message:
          "You and Pimchanok (Architecture & Design) matched! Say hello now.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
      isRead: false,
      peerAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=700&auto=format&fit=crop&q=80',
    ),
    NotificationItem(
      id: 'notif_2',
      type: NotificationType.newMessage,
      title: 'NEW MESSAGE FROM PIM',
      message:
          'Awesome! Wanna grab iced matcha at the library cafe after studio today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationItem(
      id: 'notif_3',
      type: NotificationType.likeReceived,
      title: 'SOMEONE LIKED YOUR PROFILE',
      message:
          'A student from Faculty of Business Administration sent you a Like!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_4',
      type: NotificationType.campusEvent,
      title: 'CAMPUS EVENT: MIDTERM CHILL NIGHT',
      message:
          'Acoustic jam session & coffee booth at the Central Quad this Friday from 6 PM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: true,
    ),
    NotificationItem(
      id: 'notif_5',
      type: NotificationType.systemAlert,
      title: 'STUDENT IDENTITY VERIFIED',
      message:
          'Your official university email has been verified. You have a verified student badge.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];
}
