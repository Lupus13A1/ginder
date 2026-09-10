import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/student_profile.dart';
import '../models/match_model.dart';

class DatabaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://ginder-da14f-default-rtdb.asia-southeast1.firebasedatabase.app/',
  );

  // Helper to safely convert Firebase Realtime Database Map types to Map<String, dynamic>
  Map<String, dynamic>? _mapFromSnapshot(dynamic value) {
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(k.toString(), v is Map ? _mapFromSnapshot(v) : v),
      );
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 1. USERS
  // ---------------------------------------------------------------------------

  /// Create or update a student profile (basic info)
  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String name,
    required String nickname,
    required int age,
    required String faculty,
    required String major,
    required String year,
  }) async {
    DatabaseReference userRef = _db.ref('users/$uid');

    await userRef.update({
      'uid': uid,
      'email': email,
      'name': name,
      'nickname': nickname,
      'age': age,
      'faculty': faculty,
      'major': major,
      'year': year,
      'createdAt': ServerValue.timestamp,
      'isVerifiedStudent': false, // Requires admin/university email validation
    });
  }

  /// Save or update full student profile
  Future<void> saveFullUserProfile(StudentProfile profile) async {
    DatabaseReference userRef = _db.ref('users/${profile.id}');
    final map = profile.toMap();
    map['updatedAt'] = ServerValue.timestamp;
    await userRef.update(map);
  }

  /// Get a user's profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DataSnapshot snapshot = await _db.ref('users/$uid').get();

    if (snapshot.exists && snapshot.value != null) {
      return _mapFromSnapshot(snapshot.value);
    }
    return null;
  }

  /// Seed sample students into Firebase Realtime Database if database is empty or has only 1 user
  Future<void> seedSampleUsersIfEmpty(String currentUserId) async {
    try {
      final snapshot = await _db.ref('users').get();
      int count = 0;
      if (snapshot.exists && snapshot.value is Map) {
        count = (snapshot.value as Map).length;
      }

      if (count <= 1) {
        for (final sample in StudentProfile.sampleProfiles) {
          await _db.ref('users/${sample.id}').set(sample.toMap());
        }

        // Set sample mutual likes from popular profiles so swiping right can match in RTDB
        if (currentUserId.isNotEmpty) {
          final mutualMatches = ['student_1', 'student_3', 'student_5'];
          for (final target in mutualMatches) {
            await _db.ref('swipes/${target}_$currentUserId').set({
              'fromUserId': target,
              'toUserId': currentUserId,
              'type': 'like',
              'timestamp': ServerValue.timestamp,
            });
          }
        }
      }
    } catch (_) {
      // Ignore network or permission errors during seeding
    }
  }

  /// Fetch profiles available for discovery from Firebase RTDB (excluding self and already swiped)
  Future<List<StudentProfile>> getDiscoverProfiles(String currentUserId) async {
    try {
      final Set<String> swipedUserIds = {};
      if (currentUserId.isNotEmpty) {
        final swipesSnapshot = await _db.ref('swipes').get();
        if (swipesSnapshot.exists && swipesSnapshot.value is Map) {
          final swipesMap = swipesSnapshot.value as Map;
          swipesMap.forEach((key, val) {
            if (val is Map) {
              final fromUser = val['fromUserId']?.toString();
              final toUser = val['toUserId']?.toString();
              if (fromUser == currentUserId && toUser != null) {
                swipedUserIds.add(toUser);
              }
            }
          });
        }
      }

      final usersSnapshot = await _db.ref('users').get();
      final List<StudentProfile> profiles = [];

      if (usersSnapshot.exists && usersSnapshot.value is Map) {
        final usersMap = usersSnapshot.value as Map;
        usersMap.forEach((key, val) {
          final uid = key.toString();
          if (uid != currentUserId && !swipedUserIds.contains(uid)) {
            final userMap = _mapFromSnapshot(val);
            if (userMap != null) {
              profiles.add(StudentProfile.fromMap(userMap, id: uid));
            }
          }
        });
      }

      return profiles;
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 2. SWIPES & MATCHING LOGIC
  // ---------------------------------------------------------------------------

  /// Record a right swipe (Like) and return true if mutual match occurs
  Future<bool> swipeRight(String myUid, String targetUid) async {
    String swipeId = '${myUid}_$targetUid';

    await _db.ref('swipes/$swipeId').set({
      'fromUserId': myUid,
      'toUserId': targetUid,
      'type': 'like',
      'timestamp': ServerValue.timestamp,
    });

    // Check for mutual match
    return await _checkForMatch(myUid, targetUid);
  }

  /// Record a left swipe (Pass)
  Future<void> swipeLeft(String myUid, String targetUid) async {
    String swipeId = '${myUid}_$targetUid';

    await _db.ref('swipes/$swipeId').set({
      'fromUserId': myUid,
      'toUserId': targetUid,
      'type': 'pass',
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Record a super like (Swipe Up) and create a match room
  Future<bool> superLike(String myUid, String targetUid) async {
    String swipeId = '${myUid}_$targetUid';

    await _db.ref('swipes/$swipeId').set({
      'fromUserId': myUid,
      'toUserId': targetUid,
      'type': 'superlike',
      'timestamp': ServerValue.timestamp,
    });

    await _createMatchRoom(myUid, targetUid);
    return true;
  }

  /// Rewind the last swipe (undo)
  Future<void> rewindSwipe(String myUid, String targetUid) async {
    String swipeId = '${myUid}_$targetUid';
    await _db.ref('swipes/$swipeId').remove();

    // Check and remove match room if it was created
    List<String> users = [myUid, targetUid]..sort();
    String matchId = '${users[0]}_${users[1]}';
    DataSnapshot matchSnap = await _db.ref('matches/$matchId').get();
    if (matchSnap.exists) {
      await _db.ref('matches/$matchId').remove();
    }
  }

  /// Reset all swipes made by current user so deck can be swiped again
  Future<void> resetUserSwipes(String myUid) async {
    try {
      final swipesSnapshot = await _db.ref('swipes').get();
      if (swipesSnapshot.exists && swipesSnapshot.value is Map) {
        final swipesMap = swipesSnapshot.value as Map;
        for (final entry in swipesMap.entries) {
          if (entry.value is Map) {
            final fromUser = (entry.value as Map)['fromUserId']?.toString();
            if (fromUser == myUid) {
              await _db.ref('swipes/${entry.key}').remove();
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Internal function to check if the target also liked the user
  Future<bool> _checkForMatch(String myUid, String targetUid) async {
    String reverseSwipeId = '${targetUid}_$myUid';
    DataSnapshot reverseSwipe = await _db.ref('swipes/$reverseSwipeId').get();

    if (reverseSwipe.exists && reverseSwipe.value != null) {
      final data = _mapFromSnapshot(reverseSwipe.value);
      if (data != null &&
          (data['type'] == 'like' || data['type'] == 'superlike')) {
        // It's a match! Create a chat room.
        await _createMatchRoom(myUid, targetUid);
        return true;
      }
    }
    return false;
  }

  // Cache of student profiles to avoid repeated DB lookups
  final Map<String, StudentProfile> _profileCache = {};

  /// Get student profile by UID (cached or from Firebase RTDB)
  Future<StudentProfile> getStudentProfile(String uid) async {
    if (_profileCache.containsKey(uid)) {
      return _profileCache[uid]!;
    }

    try {
      final userSnap = await _db.ref('users/$uid').get();
      if (userSnap.exists && userSnap.value != null) {
        final map = _mapFromSnapshot(userSnap.value);
        if (map != null) {
          final profile = StudentProfile.fromMap(map, id: uid);
          _profileCache[uid] = profile;
          return profile;
        }
      }
    } catch (_) {}

    // Fallback to sample profiles
    try {
      final sample = StudentProfile.sampleProfiles.firstWhere(
        (p) => p.id == uid,
      );
      _profileCache[uid] = sample;
      return sample;
    } catch (_) {
      final fallback = StudentProfile(
        id: uid,
        name: 'Campus Student',
        nickname: 'Student',
        age: 20,
        faculty: 'Faculty of Engineering',
        major: 'General Studies',
        year: 'Year 2',
        studentEmail: '$uid@email.kmutnb.ac.th',
        bio: 'Student at KMUTNB',
        photos: const [],
        interests: const ['Campus Life'],
        commonInterests: const [],
        anthemSong: 'Campus Anthem',
        anthemArtist: 'KMUTNB',
        favoriteMovie: 'Inception',
        campusHangout: 'Central Library',
      );
      _profileCache[uid] = fallback;
      return fallback;
    }
  }

  /// Create a match document when mutual like happens
  Future<void> _createMatchRoom(String uid1, String uid2) async {
    List<String> users = [uid1, uid2]..sort();
    String matchId = '${users[0]}_${users[1]}';

    final matchRef = _db.ref('matches/$matchId');
    final snap = await matchRef.get();
    if (!snap.exists) {
      await matchRef.set({
        'matchId': matchId,
        'users': {users[0]: true, users[1]: true},
        'matchedAt': ServerValue.timestamp,
        'lastMessage': 'It\'s a Match! Say hello!',
        'lastMessageAt': ServerValue.timestamp,
        'unreadCounts': {uid1: 0, uid2: 0},
      });
    }
  }

  // ---------------------------------------------------------------------------
  // 3. MESSAGING & REALTIME CHAT
  // ---------------------------------------------------------------------------

  /// Stream of all matches for real-time listener
  Stream<DatabaseEvent> getMatchesStream() {
    return _db.ref('matches').onValue;
  }

  /// Parse Firebase Realtime Database matches snapshot into MatchConversation list
  Future<List<MatchConversation>> parseMatchesFromSnapshot(
    DataSnapshot snapshot,
    String currentUserId,
  ) async {
    if (!snapshot.exists || snapshot.value is! Map) return [];

    final Map matchesMap = snapshot.value as Map;
    final List<MatchConversation> result = [];

    for (final entry in matchesMap.entries) {
      final matchId = entry.key.toString();
      final matchData = entry.value;

      if (matchData is Map) {
        final usersMap = matchData['users'];
        if (usersMap is Map && usersMap.containsKey(currentUserId)) {
          // Find the peer UID
          String? peerUid;
          usersMap.forEach((uId, isParticipant) {
            if (uId.toString() != currentUserId) {
              peerUid = uId.toString();
            }
          });

          if (peerUid != null) {
            final peerProfile = await getStudentProfile(peerUid!);
            final conversation = MatchConversation.fromFirebaseMap(
              matchId: matchId,
              map: matchData,
              peer: peerProfile,
              currentUserId: currentUserId,
            );
            result.add(conversation);
          }
        }
      }
    }

    // Sort by last message or matchedAt descending (newest first)
    result.sort((a, b) {
      final aTime = a.lastMessage?.timestamp ?? a.matchedAt;
      final bTime = b.lastMessage?.timestamp ?? b.matchedAt;
      return bTime.compareTo(aTime);
    });

    return result;
  }

  /// Send a chat message in a specific match room
  Future<void> sendChatMessage({
    required String matchId,
    required String senderId,
    required String text,
    String? imageUrl,
    String? icebreakerTag,
  }) async {
    final messagesRef = _db.ref('matches/$matchId/messages').push();
    final messageId =
        messagesRef.key ?? 'msg_${DateTime.now().millisecondsSinceEpoch}';

    await messagesRef.set({
      'id': messageId,
      'senderId': senderId,
      'text': text,
      'type': imageUrl != null ? 'image' : 'text',
      'imageUrl': ?imageUrl,
      'icebreakerTag': ?icebreakerTag,
      'isRead': false,
      'timestamp': ServerValue.timestamp,
    });

    // Determine preview text
    final previewText = text.isNotEmpty
        ? text
        : (imageUrl != null ? '[Image]' : 'Sent a message');

    // Update match document
    final matchSnap = await _db.ref('matches/$matchId').get();
    String? peerUid;
    if (matchSnap.exists && matchSnap.value is Map) {
      final usersMap = (matchSnap.value as Map)['users'];
      if (usersMap is Map) {
        usersMap.forEach((uId, _) {
          if (uId.toString() != senderId) peerUid = uId.toString();
        });
      }
    }

    final updates = <String, dynamic>{
      'lastMessage': previewText,
      'lastMessageAt': ServerValue.timestamp,
    };
    if (peerUid != null) {
      updates['unreadCounts/$peerUid'] = ServerValue.increment(1);
    }
    await _db.ref('matches/$matchId').update(updates);

    // If peer is a campus sample profile (e.g. student_1, student_2, etc.),
    // automatically trigger realistic auto-reply back into Firebase RTDB
    if (peerUid != null && peerUid!.startsWith('student_')) {
      _schedulePeerAutoReply(matchId, peerUid!, text);
    }
  }

  /// Mark all messages in match as read for the current user
  Future<void> markMatchAsRead(String matchId, String currentUserId) async {
    try {
      await _db.ref('matches/$matchId/unreadCounts/$currentUserId').set(0);

      final messagesSnap = await _db.ref('matches/$matchId/messages').get();
      if (messagesSnap.exists && messagesSnap.value is Map) {
        final messagesMap = messagesSnap.value as Map;
        final updates = <String, dynamic>{};
        messagesMap.forEach((key, val) {
          if (val is Map &&
              val['senderId'] != currentUserId &&
              val['isRead'] == false) {
            updates['$key/isRead'] = true;
          }
        });
        if (updates.isNotEmpty) {
          await _db.ref('matches/$matchId/messages').update(updates);
        }
      }
    } catch (_) {}
  }

  /// Seed an initial sample match in Firebase Realtime Database if user has no matches yet
  Future<void> seedInitialMatchIfEmpty(String currentUserId) async {
    if (currentUserId.isEmpty) return;

    try {
      final matchesSnap = await _db.ref('matches').get();
      bool hasExistingMatch = false;

      if (matchesSnap.exists && matchesSnap.value is Map) {
        final map = matchesSnap.value as Map;
        for (final val in map.values) {
          if (val is Map && val['users'] is Map) {
            if ((val['users'] as Map).containsKey(currentUserId)) {
              hasExistingMatch = true;
              break;
            }
          }
        }
      }

      if (!hasExistingMatch) {
        const targetPeerId = 'student_1'; // Pimchanok
        final users = [currentUserId, targetPeerId]..sort();
        final matchId = '${users[0]}_${users[1]}';

        final matchRef = _db.ref('matches/$matchId');
        await matchRef.set({
          'matchId': matchId,
          'users': {users[0]: true, users[1]: true},
          'matchedAt': ServerValue.timestamp,
          'lastMessage':
              'Hey Art! Wanna grab iced matcha at the library cafe? ☕',
          'lastMessageAt': ServerValue.timestamp,
          'unreadCounts': {currentUserId: 1, targetPeerId: 0},
        });

        // Seed 2 initial messages in the room
        final msg1 = matchRef.child('messages').push();
        await msg1.set({
          'id': msg1.key,
          'senderId': targetPeerId,
          'text':
              'Hi! I saw you are into Bauhaus design and specialty coffee too!',
          'type': 'text',
          'isRead': true,
          'timestamp': ServerValue.timestamp,
        });

        final msg2 = matchRef.child('messages').push();
        await msg2.set({
          'id': msg2.key,
          'senderId': targetPeerId,
          'text':
              'Wanna grab iced matcha at the library cafe after studio today? ☕',
          'type': 'text',
          'isRead': false,
          'timestamp': ServerValue.timestamp,
        });
      }
    } catch (e) {
      debugPrint('Error seeding initial match: $e');
    }
  }

  /// Realistic auto-reply for campus sample profiles
  void _schedulePeerAutoReply(
    String matchId,
    String peerId,
    String userMessage,
  ) {
    Timer(const Duration(milliseconds: 2000), () async {
      try {
        final matchSnap = await _db.ref('matches/$matchId').get();
        if (!matchSnap.exists) return;

        final responses = [
          "That sounds awesome! Let's definitely meet up around campus ☕",
          "Haha totally agree! Love your style and taste in music 🎶",
          "I'm usually studying at the library on weekdays, let me know if you are free!",
          "That's so cool! Not many students know about that spot on campus!",
          "Great! Looking forward to catching up with you soon 🙌",
        ];
        responses.shuffle();
        final replyText = responses.first;

        final replyRef = _db.ref('matches/$matchId/messages').push();
        await replyRef.set({
          'id': replyRef.key,
          'senderId': peerId,
          'text': replyText,
          'type': 'text',
          'isRead': false,
          'timestamp': ServerValue.timestamp,
        });

        await _db.ref('matches/$matchId').update({
          'lastMessage': replyText,
          'lastMessageAt': ServerValue.timestamp,
        });
      } catch (e) {
        debugPrint('Auto reply error: $e');
      }
    });
  }

  /// Stream of messages for a specific chat room
  Stream<DatabaseEvent> getMessagesStream(String matchId) {
    return _db
        .ref('matches/$matchId/messages')
        .orderByChild('timestamp')
        .onValue;
  }
}
