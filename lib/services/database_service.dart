import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    bool isVerifiedStudent = false,
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
      'isVerifiedStudent': isVerifiedStudent,
    });
  }

  /// Update verified student status
  Future<void> updateVerificationStatus(String uid, bool isVerified) async {
    await _db.ref('users/$uid/isVerifiedStudent').set(isVerified);
  }

  /// Save or update full student profile
  Future<void> saveFullUserProfile(StudentProfile profile) async {
    DatabaseReference userRef = _db.ref('users/${profile.id}');
    final map = profile.toMap();
    map['updatedAt'] = ServerValue.timestamp;
    await userRef.update(map);
  }

  /// Update or replace user structured interests
  Future<void> updateUserInterests(
    String uid,
    ProfileInterests interests,
  ) async {
    DatabaseReference interestsRef = _db.ref('users/$uid/profileInterests');
    await interestsRef.set(interests.toMap());
  }

  /// Update user activities (campus passions/hobbies)
  Future<void> updateUserActivities(String uid, List<String> activities) async {
    DatabaseReference activitiesRef = _db.ref('users/$uid/activities');
    await activitiesRef.set(activities);
    // Also mirror to 'interests' for backward compatibility
    await _db.ref('users/$uid/interests').set(activities);
  }

  /// Fetch structured interests for a user
  Future<ProfileInterests> getUserInterests(String uid) async {
    DataSnapshot snapshot = await _db.ref('users/$uid/profileInterests').get();
    if (snapshot.exists && snapshot.value != null) {
      final map = _mapFromSnapshot(snapshot.value);
      return ProfileInterests.fromMap(map);
    }
    return const ProfileInterests();
  }

  /// Get a user's profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DataSnapshot snapshot = await _db.ref('users/$uid').get();

    if (snapshot.exists && snapshot.value != null) {
      return _mapFromSnapshot(snapshot.value);
    }
    return null;
  }

  /// Permanently delete user profile and all associated data from Firebase RTDB
  Future<void> deleteUserData(String uid) async {
    try {
      // 1. Delete user profile record
      await _db.ref('users/$uid').remove();

      // 2. Clear from local memory cache
      _profileCache.remove(uid);

      // 3. Remove user notifications
      await _db.ref('notifications/$uid').remove();

      // 4. Remove all swipes where this user was sender or target
      final swipesSnapshot = await _db.ref('swipes').get();
      if (swipesSnapshot.exists) {
        for (final child in swipesSnapshot.children) {
          final val = child.value;
          final map = _mapFromSnapshot(val);
          if (map != null) {
            final fromUser = map['fromUserId']?.toString();
            final toUser = map['toUserId']?.toString();
            if (fromUser == uid || toUser == uid) {
              await child.ref.remove();
            }
          }
        }
      }

      // 5. Remove any matches involving this user
      final matchesSnapshot = await _db.ref('matches').get();
      if (matchesSnapshot.exists) {
        for (final child in matchesSnapshot.children) {
          final val = child.value;
          final map = _mapFromSnapshot(val);
          if (map != null) {
            final usersMap = map['users'];
            if (usersMap is Map && usersMap.containsKey(uid)) {
              await child.ref.remove();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error deleting user data for $uid: $e');
      rethrow;
    }
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

  /// Fetch profiles available for discovery from Firebase RTDB (excluding self, already swiped, and matched)
  Future<List<StudentProfile>> getDiscoverProfiles(String currentUserId) async {
    try {
      final auth = FirebaseAuth.instance;
      final authUid = auth.currentUser?.uid;
      final authEmail = auth.currentUser?.email?.toLowerCase().trim();

      // Collect all possible identifiers of the current user
      final Set<String> myUids = {
        if (currentUserId.isNotEmpty && currentUserId != 'my_user_id')
          currentUserId,
        if (authUid != null && authUid.isNotEmpty) authUid,
      };

      final Set<String> excludedUserIds = {};

      if (myUids.isNotEmpty) {
        // 1. Exclude users we've already swiped on (likes, passes, superlikes)
        final swipesSnapshot = await _db.ref('swipes').get();
        if (swipesSnapshot.exists) {
          for (final child in swipesSnapshot.children) {
            final val = child.value;
            if (val is Map || val is List) {
              final map = _mapFromSnapshot(val);
              if (map != null) {
                final fromUser = map['fromUserId']?.toString();
                final toUser = map['toUserId']?.toString();
                if (fromUser != null &&
                    myUids.contains(fromUser) &&
                    toUser != null) {
                  excludedUserIds.add(toUser);
                }
              }
            }
          }
        }

        // 2. Exclude users we are already matched with
        final matchesSnapshot = await _db.ref('matches').get();
        if (matchesSnapshot.exists) {
          for (final child in matchesSnapshot.children) {
            final val = child.value;
            if (val is Map || val is List) {
              final map = _mapFromSnapshot(val);
              if (map != null) {
                final usersMap = map['users'];
                if (usersMap is Map &&
                    myUids.any((myId) => usersMap.containsKey(myId))) {
                  usersMap.forEach((uId, _) {
                    if (!myUids.contains(uId.toString())) {
                      excludedUserIds.add(uId.toString());
                    }
                  });
                }
              }
            }
          }
        }

        // 3. Exclude blocked users (both whom I blocked and who blocked me)
        final blocksSnapshot = await _db.ref('blocks').get();
        if (blocksSnapshot.exists) {
          for (final child in blocksSnapshot.children) {
            final val = child.value;
            if (val is Map || val is List) {
              final map = _mapFromSnapshot(val);
              if (map != null) {
                final fromUser = map['fromUserId']?.toString();
                final toUser = map['toUserId']?.toString();
                if (fromUser != null && toUser != null) {
                  if (myUids.contains(fromUser)) {
                    excludedUserIds.add(toUser);
                  }
                  if (myUids.contains(toUser)) {
                    excludedUserIds.add(fromUser);
                  }
                }
              }
            }
          }
        }

        for (final myId in myUids) {
          final myBlockedSnap = await _db.ref('users/$myId/blockedUsers').get();
          if (myBlockedSnap.exists && myBlockedSnap.value is Map) {
            final map = myBlockedSnap.value as Map;
            map.forEach((blockedId, _) {
              excludedUserIds.add(blockedId.toString());
            });
          }
        }
      }

      // 3. Fetch all users and filter
      final usersSnapshot = await _db.ref('users').get();
      final List<StudentProfile> profiles = [];

      if (usersSnapshot.exists) {
        for (final child in usersSnapshot.children) {
          final uid = child.key;
          // Must not be current user and must not be in excluded IDs
          if (uid == null ||
              myUids.contains(uid) ||
              excludedUserIds.contains(uid)) {
            continue;
          }

          final val = child.value;
          final userMap = _mapFromSnapshot(val);
          if (userMap != null) {
            // Ignore deleted or deactivated profiles
            if (userMap['isDeleted'] == true) {
              continue;
            }

            // Also exclude by email to prevent showing self if UID varied
            final profileEmail = (userMap['email'] ?? userMap['studentEmail'])
                ?.toString()
                .toLowerCase()
                .trim();
            if (authEmail != null &&
                authEmail.isNotEmpty &&
                profileEmail == authEmail) {
              continue;
            }

            try {
              profiles.add(StudentProfile.fromMap(userMap, id: uid));
            } catch (e) {
              debugPrint('Error parsing user profile $uid: $e');
            }
          }
        }
      }

      return profiles;
    } catch (e) {
      debugPrint('Error in getDiscoverProfiles: $e');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // 2. SWIPES & MATCHING LOGIC
  // ---------------------------------------------------------------------------

  /// Check if two users have blocked each other
  Future<bool> isUserBlocked(String uid1, String uid2) async {
    try {
      final b1 = await _db.ref('blocks/${uid1}_$uid2').get();
      if (b1.exists) return true;
      final b2 = await _db.ref('blocks/${uid2}_$uid1').get();
      if (b2.exists) return true;
      final u1 = await _db.ref('users/$uid1/blockedUsers/$uid2').get();
      if (u1.exists && u1.value == true) return true;
      final u2 = await _db.ref('users/$uid2/blockedUsers/$uid1').get();
      if (u2.exists && u2.value == true) return true;
    } catch (_) {}
    return false;
  }

  /// Record a right swipe (Like) and return true if mutual match occurs
  Future<bool> swipeRight(String myUid, String targetUid) async {
    if (await isUserBlocked(myUid, targetUid)) return false;

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
    if (await isUserBlocked(myUid, targetUid)) return false;

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

  /// Unmatch user:
  /// - Removes match room and all messages in matches/$matchId
  /// - Removes mutual swipe records (swipes/${myUid}_$targetUid and swipes/${targetUid}_$myUid)
  ///   so they can encounter each other again in Discover in the future.
  Future<void> unmatchUser(String myUid, String targetUid) async {
    try {
      // 1. Delete match room and its messages
      List<String> users = [myUid, targetUid]..sort();
      String matchId = '${users[0]}_${users[1]}';
      await _db.ref('matches/$matchId').remove();

      // 2. Remove mutual swipes so they can encounter each other again in Discover
      await _db.ref('swipes/${myUid}_$targetUid').remove();
      await _db.ref('swipes/${targetUid}_$myUid').remove();
    } catch (e) {
      debugPrint('Error unmatching user: $e');
    }
  }

  /// Block user:
  /// - Immediately unmatches (removes match room and all messages)
  /// - Permanently records block in blocks/ and users/$myUid/blockedUsers
  /// - Records swipe as type 'block' so they never appear in Discover and never match again
  Future<void> blockUser(String myUid, String targetUid) async {
    try {
      // 1. Remove match room and messages
      List<String> users = [myUid, targetUid]..sort();
      String matchId = '${users[0]}_${users[1]}';
      await _db.ref('matches/$matchId').remove();

      // 2. Record in blocks node
      await _db.ref('blocks/${myUid}_$targetUid').set({
        'fromUserId': myUid,
        'toUserId': targetUid,
        'timestamp': ServerValue.timestamp,
      });

      // 3. Record in user profile
      await _db.ref('users/$myUid/blockedUsers/$targetUid').set(true);

      // 4. Record swipe as 'block'
      await _db.ref('swipes/${myUid}_$targetUid').set({
        'fromUserId': myUid,
        'toUserId': targetUid,
        'type': 'block',
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error blocking user: $e');
    }
  }

  /// Unblock user
  Future<void> unblockUser(String myUid, String targetUid) async {
    try {
      await _db.ref('blocks/${myUid}_$targetUid').remove();
      await _db.ref('users/$myUid/blockedUsers/$targetUid').remove();
      await _db.ref('swipes/${myUid}_$targetUid').remove();
    } catch (e) {
      debugPrint('Error unblocking user: $e');
    }
  }

  /// Reset all pass (left) swipes made by current user so deck can be swiped again.
  /// Like and Superlike swipes are kept so users don't see them again.
  Future<void> resetUserSwipes(String myUid) async {
    try {
      final swipesSnapshot = await _db.ref('swipes').get();
      if (swipesSnapshot.exists) {
        for (final child in swipesSnapshot.children) {
          final val = child.value;
          if (val is Map || val is List) {
            final map = _mapFromSnapshot(val);
            if (map != null) {
              final fromUser = map['fromUserId']?.toString();
              final type = map['type']?.toString();
              if (fromUser == myUid && type == 'pass') {
                if (child.key != null) {
                  await _db.ref('swipes/${child.key}').remove();
                }
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  /// Internal function to check if the target also liked the user
  Future<bool> _checkForMatch(String myUid, String targetUid) async {
    if (await isUserBlocked(myUid, targetUid)) return false;

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
