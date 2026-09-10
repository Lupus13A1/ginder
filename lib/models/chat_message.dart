/// Data model representing a chat message
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isRead;
  final String? imageUrl;
  final String? icebreakerTag;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.isRead = true,
    this.imageUrl,
    this.icebreakerTag,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isFromMe,
    bool? isRead,
    String? imageUrl,
    String? icebreakerTag,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isFromMe: isFromMe ?? this.isFromMe,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      icebreakerTag: icebreakerTag ?? this.icebreakerTag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': ?imageUrl,
      'icebreakerTag': ?icebreakerTag,
    };
  }

  factory ChatMessage.fromMap(
    Map<dynamic, dynamic> map, {
    required String currentUserId,
    String? id,
  }) {
    final senderId = map['senderId']?.toString() ?? '';
    final rawTime = map['timestamp'];
    DateTime time;
    if (rawTime is int) {
      time = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else if (rawTime is String) {
      time = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }

    return ChatMessage(
      id: id ?? map['id']?.toString() ?? '',
      senderId: senderId,
      text: map['text']?.toString() ?? '',
      timestamp: time,
      isFromMe: senderId == currentUserId,
      isRead: map['isRead'] == true,
      imageUrl: map['imageUrl']?.toString(),
      icebreakerTag: map['icebreakerTag']?.toString(),
    );
  }
}
