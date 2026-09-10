import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_profile.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  StudentProfile _currentUser = StudentProfile.currentUser;
  bool _isProfileSetupComplete = true;

  // Settings
  double _maxDistanceKm = 5.0;
  String _preferredFaculty = 'All Faculties';
  RangeValues _ageRange = const RangeValues(18, 26);
  bool _incognitoMode = false;
  bool _showOnlineStatus = true;
  bool _notifyNewMatches = true;
  bool _notifyMessages = true;
  bool _notifyLikes = true;
  final List<String> _blockedUsers = ['blocked_user_99'];

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserProfile(user.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final data = await _db.getUserProfile(uid);
      if (data != null) {
        _currentUser = StudentProfile.fromMap(data, id: uid);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  StudentProfile get currentUser => _currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isOnboarded => true;
  bool get isProfileSetupComplete => _isProfileSetupComplete;

  double get maxDistanceKm => _maxDistanceKm;
  String get preferredFaculty => _preferredFaculty;
  RangeValues get ageRange => _ageRange;
  bool get incognitoMode => _incognitoMode;
  bool get showOnlineStatus => _showOnlineStatus;
  bool get notifyNewMatches => _notifyNewMatches;
  bool get notifyMessages => _notifyMessages;
  bool get notifyLikes => _notifyLikes;
  List<String> get blockedUsers => List.unmodifiable(_blockedUsers);

  bool _isValidEmailDomain(String email) {
    return email.trim().toLowerCase().endsWith('@email.kmutnb.ac.th');
  }

  Future<void> login({required String email, required String password}) async {
    if (!_isValidEmailDomain(email)) {
      throw 'Please use your @email.kmutnb.ac.th student email.';
    }
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        throw 'Please check your inbox and click the verification link before logging in.';
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    }
  }

  Future<void> register({
    required String name,
    required String nickname,
    required int age,
    required String faculty,
    required String major,
    required String year,
    required String email,
    required String password,
  }) async {
    if (!_isValidEmailDomain(email)) {
      throw 'Registration restricted to @email.kmutnb.ac.th domain.';
    }
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      await _db.saveUserProfile(
        uid: uid,
        email: email,
        name: name,
        nickname: nickname,
        age: age,
        faculty: faculty,
        major: major,
        year: year,
      );

      await cred.user!.sendEmailVerification();
      await _auth.signOut(); // Prevent automatic login until verified

      throw 'VERIFICATION_REQUIRED';
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration failed';
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      // Force Google login screen to only allow KMUTNB domain
      googleProvider.setCustomParameters({'hd': 'email.kmutnb.ac.th'});

      UserCredential cred;

      if (kIsWeb) {
        cred = await _auth.signInWithPopup(googleProvider);
      } else {
        // On mobile, this will open a secure webview for Google Auth
        cred = await _auth.signInWithProvider(googleProvider);
      }

      final email = cred.user!.email ?? '';

      // Double check the domain in case user found a workaround
      if (!_isValidEmailDomain(email)) {
        await cred.user!
            .delete(); // Delete the mistakenly created Firebase Auth user
        await logout();
        throw 'Access denied. You must use an @email.kmutnb.ac.th account.';
      }

      String uid = cred.user!.uid;
      final existingData = await _db.getUserProfile(uid);

      if (existingData == null) {
        // First time signing in with this Google account
        await _db.saveUserProfile(
          uid: uid,
          email: email,
          name: cred.user!.displayName ?? 'New Student',
          nickname: cred.user!.displayName?.split(' ').first ?? 'Student',
          age: 20, // Cannot get age from Google easily, default to 20
          faculty: 'Unknown',
          major: 'Unknown',
          year: 'Unknown',
        );
        _isProfileSetupComplete = false;
      }

      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  void completeProfileSetup({
    required String bio,
    required List<String> interests,
    required String anthemSong,
    required String anthemArtist,
    required String favoriteMovie,
    required String campusHangout,
    required List<String> photos,
  }) {
    // Ideally this would save to Realtime Database as well
    _currentUser = _currentUser.copyWith(
      bio: bio,
      interests: interests,
      anthemSong: anthemSong,
      anthemArtist: anthemArtist,
      favoriteMovie: favoriteMovie,
      campusHangout: campusHangout,
      photos: photos,
      profileCompleteness: 1.0,
    );
    _isProfileSetupComplete = true;
    _db.saveFullUserProfile(_currentUser);
    notifyListeners();
  }

  void updateProfile(StudentProfile updated) {
    _currentUser = updated;
    _db.saveFullUserProfile(updated);
    notifyListeners();
  }

  void completeOnboarding() {
    // Should save to local storage in real app
    notifyListeners();
  }

  void updateSettings({
    double? maxDistanceKm,
    String? preferredFaculty,
    RangeValues? ageRange,
    bool? incognitoMode,
    bool? showOnlineStatus,
    bool? notifyNewMatches,
    bool? notifyMessages,
    bool? notifyLikes,
  }) {
    if (maxDistanceKm != null) _maxDistanceKm = maxDistanceKm;
    if (preferredFaculty != null) _preferredFaculty = preferredFaculty;
    if (ageRange != null) _ageRange = ageRange;
    if (incognitoMode != null) _incognitoMode = incognitoMode;
    if (showOnlineStatus != null) _showOnlineStatus = showOnlineStatus;
    if (notifyNewMatches != null) _notifyNewMatches = notifyNewMatches;
    if (notifyMessages != null) _notifyMessages = notifyMessages;
    if (notifyLikes != null) _notifyLikes = notifyLikes;
    notifyListeners();
  }

  void blockUser(String userId) {
    if (!_blockedUsers.contains(userId)) {
      _blockedUsers.add(userId);
      notifyListeners();
    }
  }

  void unblockUser(String userId) {
    _blockedUsers.remove(userId);
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = StudentProfile.currentUser; // reset to default
    notifyListeners();
  }
}
