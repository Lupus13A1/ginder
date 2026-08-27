import 'student_profile.dart';
import 'chat_message.dart';

/// Data model representing a match item and conversation thread
class MatchConversation {
  final String id;
  final StudentProfile peer;
  final DateTime matchedAt;
  final List<ChatMessage> messages;
  final int unreadCount;
  final bool isOnline;

  const MatchConversation({
    required this.id,
    required this.peer,
    required this.matchedAt,
    this.messages = const [],
    this.unreadCount = 0,
    this.isOnline = true,
  });

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  MatchConversation copyWith({
    String? id,
    StudentProfile? peer,
    DateTime? matchedAt,
    List<ChatMessage>? messages,
    int? unreadCount,
    bool? isOnline,
  }) {
    return MatchConversation(
      id: id ?? this.id,
      peer: peer ?? this.peer,
      matchedAt: matchedAt ?? this.matchedAt,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  /// Initial sample matches and conversations
  static List<MatchConversation> get sampleMatches {
    final profiles = StudentProfile.sampleProfiles;

    return [
      MatchConversation(
        id: 'conv_1',
        peer: profiles[0], // Pimchanok (Arch)
        matchedAt: DateTime.now().subtract(const Duration(minutes: 42)),
        unreadCount: 2,
        isOnline: true,
        messages: [
          ChatMessage(
            id: 'm_1_1',
            senderId: profiles[0].id,
            text:
                'Hey Art! I saw you are into Bauhaus design too! Did you check out the new design exhibition at the faculty gallery?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
            isFromMe: false,
          ),
          ChatMessage(
            id: 'm_1_2',
            senderId: 'my_user_id',
            text:
                'Hi Pim! Yes! I spent 2 hours there yesterday admiring the typography posters.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
            isFromMe: true,
          ),
          ChatMessage(
            id: 'm_1_3',
            senderId: profiles[0].id,
            text:
                'Awesome! Wanna grab iced matcha at the library cafe after studio today?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isFromMe: false,
            isRead: false,
          ),
        ],
      ),
      MatchConversation(
        id: 'conv_2',
        peer: profiles[1], // Tanawat (Eng)
        matchedAt: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isOnline: true,
        messages: [
          ChatMessage(
            id: 'm_2_1',
            senderId: profiles[1].id,
            text: 'Yo! Ready for the campus badminton tournament this weekend?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isFromMe: false,
          ),
          ChatMessage(
            id: 'm_2_2',
            senderId: 'my_user_id',
            text: 'Definitely, let us book court 3 on Friday afternoon!',
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isFromMe: true,
          ),
        ],
      ),
      MatchConversation(
        id: 'conv_3',
        peer: profiles[2], // Chanya (Comm Arts)
        matchedAt: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
        isOnline: false,
        messages: [
          ChatMessage(
            id: 'm_3_1',
            senderId: profiles[2].id,
            text:
                'Loved your favorite movie pick "Metropolis"! A timeless classic.',
            timestamp: DateTime.now().subtract(const Duration(hours: 8)),
            isFromMe: false,
            isRead: false,
          ),
        ],
      ),
      MatchConversation(
        id: 'conv_4',
        peer: profiles[4], // Nattaporn (BBA)
        matchedAt: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
        messages: [],
      ),
    ];
  }
}
