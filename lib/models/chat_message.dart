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
}
