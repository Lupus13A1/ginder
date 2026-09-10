import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/match_model.dart';
import '../models/student_profile.dart';
import '../services/database_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MatchConversation> _conversations = [];
  String? _activeConversationId;
  String _currentUserId = '';
  StreamSubscription<DatabaseEvent>? _matchesSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _isLoading = true;

  ChatProvider() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        initForUser(user.uid);
      } else {
        _matchesSubscription?.cancel();
        _currentUserId = '';
        _conversations = [];
        _isLoading = false;
        notifyListeners();
      }
    });

    final currentUid = _auth.currentUser?.uid;
    if (currentUid != null) {
      initForUser(currentUid);
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  bool get isLoading => _isLoading;
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

  /// Initialize real-time match and chat streams for authenticated user
  Future<void> initForUser(String uid) async {
    if (_currentUserId == uid && _matchesSubscription != null) return;

    _currentUserId = uid;
    _isLoading = true;
    notifyListeners();

    await _matchesSubscription?.cancel();

    // Ensure user has initial sample match to chat with if database is fresh
    await _db.seedInitialMatchIfEmpty(uid);

    _matchesSubscription = _db.getMatchesStream().listen((event) async {
      try {
        final parsed = await _db.parseMatchesFromSnapshot(
          event.snapshot,
          _currentUserId,
        );
        _conversations = parsed;
      } catch (e) {
        debugPrint('Error parsing matches stream: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void setActiveConversation(String? id) {
    _activeConversationId = id;
    if (id != null) {
      markAsRead(id);
    }
    notifyListeners();
  }

  /// Create match in Firebase when a match is found from Discover swipe
  Future<void> addMatchFromDiscover(StudentProfile peer) async {
    final myUid = _currentUserId.isNotEmpty
        ? _currentUserId
        : (_auth.currentUser?.uid ?? 'my_user_id');

    final users = [myUid, peer.id]..sort();
    final matchId = '${users[0]}_${users[1]}';

    final existing = getConversationById(matchId);
    if (existing == null) {
      // Create match document in Firebase
      final matchRef = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL:
            'https://ginder-da14f-default-rtdb.asia-southeast1.firebasedatabase.app/',
      ).ref('matches/$matchId');

      await matchRef.set({
        'matchId': matchId,
        'users': {users[0]: true, users[1]: true},
        'matchedAt': ServerValue.timestamp,
        'lastMessage': 'It\'s a Match! Start the conversation.',
        'lastMessageAt': ServerValue.timestamp,
        'unreadCounts': {myUid: 0, peer.id: 0},
      });
    }
  }

  /// Send a real-time message via Firebase Realtime Database
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
    String? icebreakerTag,
  }) async {
    final senderId = _currentUserId.isNotEmpty
        ? _currentUserId
        : (_auth.currentUser?.uid ?? 'my_user_id');

    await _db.sendChatMessage(
      matchId: conversationId,
      senderId: senderId,
      text: text,
      imageUrl: imageUrl,
      icebreakerTag: icebreakerTag,
    );
  }

  /// Mark all messages in conversation as read
  void markAsRead(String conversationId) {
    if (_currentUserId.isNotEmpty) {
      _db.markMatchAsRead(conversationId, _currentUserId);
    }
  }
}
