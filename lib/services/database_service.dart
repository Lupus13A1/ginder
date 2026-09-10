import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/student_profile.dart';

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

  /// Create a match document when mutual like happens
  Future<void> _createMatchRoom(String uid1, String uid2) async {
    // Sort UIDs alphabetically to ensure consistent Match ID
    List<String> users = [uid1, uid2]..sort();
    String matchId = '${users[0]}_${users[1]}';

    await _db.ref('matches/$matchId').set({
      'matchId': matchId,
      'users': {users[0]: true, users[1]: true},
      'matchedAt': ServerValue.timestamp,
      'lastMessage': '',
      'lastMessageAt': ServerValue.timestamp,
      'unreadCounts': {uid1: 0, uid2: 0},
    });

    // Optionally: Trigger notifications to both users here
  }

  // ---------------------------------------------------------------------------
  // 3. MESSAGING
  // ---------------------------------------------------------------------------

  /// Send a chat message in a specific match room
  Future<void> sendMessage(String matchId, String senderId, String text) async {
    DatabaseReference messagesRef = _db.ref('matches/$matchId/messages').push();

    await messagesRef.set({
      'id': messagesRef.key,
      'senderId': senderId,
      'text': text,
      'type': 'text',
      'isRead': false,
      'timestamp': ServerValue.timestamp,
    });

    // Update the last message preview on the match document
    await _db.ref('matches/$matchId').update({
      'lastMessage': text,
      'lastMessageAt': ServerValue.timestamp,
      // TODO: Increment unread count for the other user
    });
  }

  /// Stream of messages for a chat room (Real-time listener)
  Stream<DatabaseEvent> getMessagesStream(String matchId) {
    return _db
        .ref('matches/$matchId/messages')
        .orderByChild('timestamp')
        .onValue;
  }
}
