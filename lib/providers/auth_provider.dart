import 'package:flutter/material.dart';
import '../models/student_profile.dart';

class AuthProvider extends ChangeNotifier {
  StudentProfile _currentUser = StudentProfile.currentUser;
  bool _isAuthenticated = true;
  bool _isOnboarded = true;
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

  StudentProfile get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOnboarded => _isOnboarded;
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

  void login({required String email, required String password}) {
    _isAuthenticated = true;
    notifyListeners();
  }

  void register({
    required String name,
    required String nickname,
    required int age,
    required String faculty,
    required String major,
    required String year,
    required String email,
    required String password,
  }) {
    _currentUser = _currentUser.copyWith(
      name: name,
      nickname: nickname,
      age: age,
      faculty: faculty,
      major: major,
      year: year,
      studentEmail: email,
    );
    _isAuthenticated = true;
    _isProfileSetupComplete = false;
    notifyListeners();
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
    notifyListeners();
  }

  void updateProfile(StudentProfile updated) {
    _currentUser = updated;
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboarded = true;
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

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
