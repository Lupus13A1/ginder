import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/match_model.dart';
import '../models/student_profile.dart';

class ChatProvider extends ChangeNotifier {
  List<MatchConversation> _conversations = [];
  String? _activeConversationId;

  ChatProvider() {
    _conversations = MatchConversation.sampleMatches;
  }

  List<MatchConversation> get conversations =>
      List.unmodifiable(_conversations);

  List<MatchConversation> get newMatches =>
      _conversations.where((c) => c.messages.isEmpty).toList();

  List<MatchConversation> get activeChats =>
      _conversations.where((c) => c.messages.isNotEmpty).toList();

  int get totalUnreadCount =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  MatchConversation? get activeConversation {
    if (_activeConversationId == null) return null;
    return getConversationById(_activeConversationId!);
  }

  MatchConversation? getConversationById(String id) {
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  MatchConversation? getConversationByPeerId(String peerId) {
    try {
      return _conversations.firstWhere((c) => c.peer.id == peerId);
    } catch (_) {
      return null;
    }
  }

  void setActiveConversation(String? id) {
    _activeConversationId = id;
    if (id != null) {
      markAsRead(id);
    }
    notifyListeners();
  }

  void addMatchFromDiscover(StudentProfile profile) {
    final existing = getConversationByPeerId(profile.id);
    if (existing == null) {
      final newConv = MatchConversation(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        peer: profile,
        matchedAt: DateTime.now(),
        messages: [],
        unreadCount: 0,
      );
      _conversations.insert(0, newConv);
      notifyListeners();
    }
  }

  void sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
    String? icebreakerTag,
  }) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final conv = _conversations[index];
    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'my_user_id',
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
      isRead: true,
      imageUrl: imageUrl,
      icebreakerTag: icebreakerTag,
    );

    final updatedMessages = List<ChatMessage>.from(conv.messages)..add(newMsg);
    final updatedConv = conv.copyWith(messages: updatedMessages);

    _conversations.removeAt(index);
    _conversations.insert(0, updatedConv);
    notifyListeners();

    // Trigger realistic automated peer response after 1.8 seconds
    _schedulePeerResponse(conversationId, conv.peer);
  }

  void _schedulePeerResponse(String conversationId, StudentProfile peer) {
    Timer(const Duration(milliseconds: 1800), () {
      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index == -1) return;

      final conv = _conversations[index];
      final responses = [
        "Sounds great! Are you free after 4 PM around the ${peer.campusHangout}?",
        "Haha totally agree! Love your style and taste in music.",
        "Let's definitely meet up! I'm usually studying at the library cafe on weekdays.",
        "That's so cool! Not many people from other faculties know about that.",
      ];
      final responseText = (responses..shuffle()).first;

      final peerMsg = ChatMessage(
        id: 'msg_peer_${DateTime.now().millisecondsSinceEpoch}',
        senderId: peer.id,
        text: responseText,
        timestamp: DateTime.now(),
        isFromMe: false,
        isRead: _activeConversationId == conversationId,
      );

      final updatedMessages = List<ChatMessage>.from(conv.messages)
        ..add(peerMsg);
      final updatedConv = conv.copyWith(
        messages: updatedMessages,
        unreadCount: _activeConversationId == conversationId
            ? 0
            : conv.unreadCount + 1,
      );

      _conversations.removeAt(index);
      _conversations.insert(0, updatedConv);
      notifyListeners();
    });
  }

  void markAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) return;

    final conv = _conversations[index];
    if (conv.unreadCount > 0) {
      final updatedMessages = conv.messages
          .map((m) => m.copyWith(isRead: true))
          .toList();
      _conversations[index] = conv.copyWith(
        unreadCount: 0,
        messages: updatedMessages,
      );
      notifyListeners();
    }
  }
}
