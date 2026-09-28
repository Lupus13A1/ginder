import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_profile.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _onboardingCompleteKey = 'has_completed_onboarding';
  static const String _blockedUsersKey = 'blocked_users_list';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  StudentProfile _currentUser = StudentProfile.currentUser;
  bool _isProfileSetupComplete = false;
  bool _isOnboarded = false;
  bool _hasLoadedOnboarded = false;

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

  AuthProvider([SharedPreferences? prefs]) {
    if (prefs != null) {
      _isOnboarded = prefs.getBool(_onboardingCompleteKey) ?? false;
      _hasLoadedOnboarded = true;
      final list = prefs.getStringList(_blockedUsersKey);
      if (list != null) {
        for (final uid in list) {
          if (!_blockedUsers.contains(uid)) {
            _blockedUsers.add(uid);
          }
        }
      }
    } else {
      _loadOnboardedState();
      _loadBlockedUsers();
    }
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (!_isOnboarded) {
          await completeOnboarding();
        }
        await _fetchUserProfile(user.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _loadBlockedUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_blockedUsersKey);
      if (list != null) {
        for (final uid in list) {
          if (!_blockedUsers.contains(uid)) {
            _blockedUsers.add(uid);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading blocked users: $e');
    }
  }

  Future<void> _loadOnboardedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboarded = prefs.getBool(_onboardingCompleteKey) ?? false;
      _hasLoadedOnboarded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading onboarding state: $e');
      _hasLoadedOnboarded = true;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final data = await _db.getUserProfile(uid);
      final isEmailVerified = _auth.currentUser?.emailVerified ?? false;
      if (data != null) {
        _currentUser = StudentProfile.fromMap(data, id: uid);
        if (isEmailVerified && !_currentUser.isVerifiedStudent) {
          _currentUser = _currentUser.copyWith(isVerifiedStudent: true);
          _db.updateVerificationStatus(uid, true);
        }
        _isProfileSetupComplete = _currentUser.photos.isNotEmpty;
      } else {
        _isProfileSetupComplete = false;
        _currentUser = _currentUser.copyWith(
          id: uid,
          isVerifiedStudent: isEmailVerified,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  StudentProfile get currentUser {
    final isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    if (isEmailVerified && !_currentUser.isVerifiedStudent) {
      _currentUser = _currentUser.copyWith(isVerifiedStudent: true);
      if (_auth.currentUser != null) {
        _db.updateVerificationStatus(_auth.currentUser!.uid, true);
      }
    }
    return _currentUser;
  }

  bool get isAuthenticated => _auth.currentUser != null;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  String? get firebaseUserId => _auth.currentUser?.uid;
  String? get firebaseUserEmail => _auth.currentUser?.email;
  bool get isOnboarded => _isOnboarded;
  bool get hasLoadedOnboarded => _hasLoadedOnboarded;
  bool get isProfileSetupComplete =>
      _isProfileSetupComplete && _currentUser.photos.isNotEmpty;

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

  /// Resend verification email for the currently signed-in user.
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'No user is currently signed in.';
    }
    if (user.emailVerified) {
      throw 'Email is already verified.';
    }
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send verification email.';
    }
  }

  /// Reload the current user from Firebase to refresh emailVerified status.
  Future<bool> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final isVerified = _auth.currentUser?.emailVerified ?? false;
    if (isVerified) {
      if (!_currentUser.isVerifiedStudent) {
        _currentUser = _currentUser.copyWith(isVerifiedStudent: true);
        await _db.updateVerificationStatus(user.uid, true);
      }
      notifyListeners();
    }
    return isVerified;
  }

  Future<void> login({required String email, required String password}) async {
    if (!_isValidEmailDomain(email)) {
      throw 'Access restricted. Please use your @email.kmutnb.ac.th student email.';
    }

    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        // Don't sign out — let the user land on the verification screen
        throw 'EMAIL_NOT_VERIFIED';
      }

      await _fetchUserProfile(cred.user!.uid);
      await completeOnboarding();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      throw 'Please enter your email address.';
    }
    if (!_isValidEmailDomain(email)) {
      throw 'Please use your @email.kmutnb.ac.th student email.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to send password reset email.';
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
      await _fetchUserProfile(uid);
      await completeOnboarding();
      notifyListeners();
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
        // Use native Google Sign-In on mobile for faster performance
        final googleSignIn = GoogleSignIn.instance;

        final GoogleSignInAccount googleUser = await googleSignIn
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        cred = await _auth.signInWithCredential(credential);
      }

      final email = cred.user!.email ?? '';

      // Server-side domain check — the `hd` parameter can be bypassed,
      // so we must verify the returned email domain ourselves.
      if (!_isValidEmailDomain(email)) {
        await cred.user!.delete();
        await logout();
        throw 'Access denied. You must use an @email.kmutnb.ac.th account.';
      }

      // Check email verified status from the OAuth provider.
      // Google accounts with verified emails are trusted by Firebase,
      // but we still enforce the check for consistency.
      if (!(cred.user!.emailVerified)) {
        throw 'EMAIL_NOT_VERIFIED';
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
          faculty: 'Faculty of Engineering',
          major: 'General',
          year: 'Year 1 (Freshman)',
          isVerifiedStudent: true,
        );
        _isProfileSetupComplete = false;
      }

      await _fetchUserProfile(uid);
      await completeOnboarding();
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
    final isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    _currentUser = _currentUser.copyWith(
      bio: bio,
      interests: interests,
      anthemSong: anthemSong,
      anthemArtist: anthemArtist,
      favoriteMovie: favoriteMovie,
      campusHangout: campusHangout,
      photos: photos,
      isVerifiedStudent: isEmailVerified || _currentUser.isVerifiedStudent,
    );
    _isProfileSetupComplete = true;
    _db.saveFullUserProfile(_currentUser);
    notifyListeners();
  }

  void updateProfile(StudentProfile updated) {
    final isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    _currentUser = updated.copyWith(
      isVerifiedStudent: isEmailVerified || updated.isVerifiedStudent,
    );
    _db.saveFullUserProfile(_currentUser);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboarded = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
    } catch (e) {
      debugPrint('Error saving onboarding state: $e');
    }
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

  Future<void> blockUser(String userId) async {
    if (!_blockedUsers.contains(userId)) {
      _blockedUsers.add(userId);
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_blockedUsersKey, _blockedUsers);
        final myUid = firebaseUserId ?? currentUser.id;
        await _db.blockUser(myUid, userId);
      } catch (e) {
        debugPrint('Error persisting block user: $e');
      }
    }
  }

  Future<void> unblockUser(String userId) async {
    _blockedUsers.remove(userId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_blockedUsersKey, _blockedUsers);
      final myUid = firebaseUserId ?? currentUser.id;
      await _db.unblockUser(myUid, userId);
    } catch (e) {
      debugPrint('Error persisting unblock user: $e');
    }
  }

  Future<void> unmatchUser(String userId) async {
    try {
      final myUid = firebaseUserId ?? currentUser.id;
      await _db.unmatchUser(myUid, userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unmatching user: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Error signing out of Google: $e');
      }
    }
    _currentUser = StudentProfile.currentUser; // reset to default
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final uid = user.uid;
        // Delete all database records (profile, swipes, matches, notifications) first
        await _db.deleteUserData(uid);
        // Then delete the authentication user
        await user.delete();
        await logout();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Please log out and log back in to delete your account.';
      }
      throw e.message ?? 'Failed to delete account';
    } catch (e) {
      throw e.toString();
    }
  }
}
