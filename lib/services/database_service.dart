import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 1. USERS COLLECTION
  // ---------------------------------------------------------------------------

  /// Create or update a student profile
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
    DocumentReference userRef = _db.collection('users').doc(uid);

    await userRef.set({
      'uid': uid,
      'email': email,
      'name': name,
      'nickname': nickname,
      'age': age,
      'faculty': faculty,
      'major': major,
      'year': year,
      'createdAt': FieldValue.serverTimestamp(),
      'isVerifiedStudent': false, // Requires admin/university email validation
    }, SetOptions(merge: true));
  }

  /// Get a user's profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 2. SWIPES & MATCHING LOGIC
  // ---------------------------------------------------------------------------

  /// Record a right swipe (Like)
  Future<void> swipeRight(String myUid, String targetUid) async {
    String swipeId = '${myUid}_$targetUid';

    await _db.collection('swipes').doc(swipeId).set({
      'fromUserId': myUid,
      'toUserId': targetUid,
      'type': 'like',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Check for mutual match
    await _checkForMatch(myUid, targetUid);
  }

  /// Internal function to check if the target also liked the user
  Future<void> _checkForMatch(String myUid, String targetUid) async {
    String reverseSwipeId = '${targetUid}_$myUid';
    DocumentSnapshot reverseSwipe = await _db
        .collection('swipes')
        .doc(reverseSwipeId)
        .get();

    if (reverseSwipe.exists && (reverseSwipe.data() as Map)['type'] == 'like') {
      // It's a match! Create a chat room.
      await _createMatchRoom(myUid, targetUid);
    }
  }

  /// Create a match document when mutual like happens
  Future<void> _createMatchRoom(String uid1, String uid2) async {
    // Sort UIDs alphabetically to ensure consistent Match ID
    List<String> users = [uid1, uid2]..sort();
    String matchId = '${users[0]}_${users[1]}';

    await _db.collection('matches').doc(matchId).set({
      'matchId': matchId,
      'users': users, // Array for easy querying via array-contains
      'matchedAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCounts': {uid1: 0, uid2: 0},
    });

    // Optionally: Trigger notifications to both users here
  }

  // ---------------------------------------------------------------------------
  // 3. MESSAGING
  // ---------------------------------------------------------------------------

  /// Send a chat message in a specific match room
  Future<void> sendMessage(String matchId, String senderId, String text) async {
    CollectionReference messagesRef = _db
        .collection('matches')
        .doc(matchId)
        .collection('messages');

    await messagesRef.add({
      'senderId': senderId,
      'text': text,
      'type': 'text',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the last message preview on the match document
    await _db.collection('matches').doc(matchId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      // TODO: Increment unread count for the other user
    });
  }

  /// Stream of messages for a chat room (Real-time listener)
  Stream<QuerySnapshot> getMessagesStream(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
