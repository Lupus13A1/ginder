import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_profile.dart';
import '../services/database_service.dart';

enum SwipeDirection { left, right, up }

class DiscoverProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<StudentProfile> _profiles = [];
  final List<StudentProfile> _passedProfiles = [];
  final List<StudentProfile> _likedProfiles = [];
  final List<StudentProfile> _superLikedProfiles = [];
  StudentProfile? _lastSwipedProfile;
  SwipeDirection? _lastSwipeDirection;

  bool _isLoading = false;
  String? _errorMessage;
  String _currentUserId = '';

  // Filters
  String _selectedFaculty = 'All';
  String _selectedYear = 'All';
  double _maxDistance = 10.0;
  String _searchQuery = '';

  StudentProfile? _currentMatchProfile;

  DiscoverProvider() {
    loadProfiles();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<StudentProfile> get profiles => List.unmodifiable(_filteredProfiles);
  StudentProfile? get currentCard =>
      _filteredProfiles.isNotEmpty ? _filteredProfiles.first : null;
  bool get hasCards => _filteredProfiles.isNotEmpty;
  bool get canRewind => _lastSwipedProfile != null;
  StudentProfile? get currentMatchProfile => _currentMatchProfile;

  String get selectedFaculty => _selectedFaculty;
  String get selectedYear => _selectedYear;
  double get maxDistance => _maxDistance;
  String get searchQuery => _searchQuery;

  List<StudentProfile> get _filteredProfiles {
    return _profiles.where((p) {
      if (_selectedFaculty != 'All' &&
          !p.faculty.toLowerCase().contains(_selectedFaculty.toLowerCase())) {
        return false;
      }
      if (_selectedYear != 'All' &&
          !p.year.toLowerCase().contains(_selectedYear.toLowerCase())) {
        return false;
      }
      if (p.distanceKm > _maxDistance) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName =
            p.name.toLowerCase().contains(q) ||
            p.nickname.toLowerCase().contains(q);
        final matchFaculty = p.faculty.toLowerCase().contains(q);
        final matchMajor = p.major.toLowerCase().contains(q);
        final matchInterest = p.interests.any(
          (i) => i.toLowerCase().contains(q),
        );
        if (!matchName && !matchFaculty && !matchMajor && !matchInterest) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> loadProfiles({String? uid, bool forceRefresh = false}) async {
    if (uid != null && uid.isNotEmpty) {
      _currentUserId = uid;
    }
    if (_currentUserId.isEmpty) {
      _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Seed sample users into Firebase Realtime Database if database is empty
      await _db.seedSampleUsersIfEmpty(_currentUserId);

      // 2. Fetch unswiped profiles from Firebase Realtime Database
      final fetchedProfiles = await _db.getDiscoverProfiles(_currentUserId);
      _profiles = fetchedProfiles;
      _passedProfiles.clear();
      _likedProfiles.clear();
      _superLikedProfiles.clear();
      _lastSwipedProfile = null;
      _lastSwipeDirection = null;
      _currentMatchProfile = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('DiscoverProvider loadProfiles error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetDeck({String? uid}) async {
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (_currentUserId.isNotEmpty
              ? _currentUserId
              : (FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id'));
    _currentUserId = effectiveUid;

    _isLoading = true;
    notifyListeners();

    try {
      await _db.resetUserSwipes(effectiveUid);
      await loadProfiles(uid: effectiveUid, forceRefresh: true);
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> likeCurrent({String? uid}) async {
    if (!hasCards) return false;
    final card = currentCard!;
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (_currentUserId.isNotEmpty
              ? _currentUserId
              : (FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id'));

    // Optimistic UI update
    _profiles.remove(card);
    _likedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.right;
    notifyListeners();

    try {
      final isMatch = await _db.swipeRight(effectiveUid, card.id);
      if (isMatch) {
        _currentMatchProfile = card;
        notifyListeners();
      }
      return isMatch;
    } catch (e) {
      debugPrint('Error swiping right: $e');
      return false;
    }
  }

  Future<void> passCurrent({String? uid}) async {
    if (!hasCards) return;
    final card = currentCard!;
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (_currentUserId.isNotEmpty
              ? _currentUserId
              : (FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id'));

    // Optimistic UI update
    _profiles.remove(card);
    _passedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.left;
    notifyListeners();

    try {
      await _db.swipeLeft(effectiveUid, card.id);
    } catch (e) {
      debugPrint('Error swiping left: $e');
    }
  }

  Future<bool> superLikeCurrent({String? uid}) async {
    if (!hasCards) return false;
    final card = currentCard!;
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (_currentUserId.isNotEmpty
              ? _currentUserId
              : (FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id'));

    // Optimistic UI update
    _profiles.remove(card);
    _superLikedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.up;
    _currentMatchProfile = card;
    notifyListeners();

    try {
      await _db.superLike(effectiveUid, card.id);
      return true;
    } catch (e) {
      debugPrint('Error super liking: $e');
      return true;
    }
  }

  Future<void> rewind({String? uid}) async {
    if (_lastSwipedProfile == null) return;
    final lastCard = _lastSwipedProfile!;
    final effectiveUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (_currentUserId.isNotEmpty
              ? _currentUserId
              : (FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id'));

    _profiles.insert(0, lastCard);
    if (_lastSwipeDirection == SwipeDirection.right) {
      _likedProfiles.remove(lastCard);
    } else if (_lastSwipeDirection == SwipeDirection.left) {
      _passedProfiles.remove(lastCard);
    } else if (_lastSwipeDirection == SwipeDirection.up) {
      _superLikedProfiles.remove(lastCard);
    }
    _lastSwipedProfile = null;
    _lastSwipeDirection = null;
    notifyListeners();

    try {
      await _db.rewindSwipe(effectiveUid, lastCard.id);
    } catch (e) {
      debugPrint('Error rewinding swipe: $e');
    }
  }

  void clearMatchCelebration() {
    _currentMatchProfile = null;
    notifyListeners();
  }

  void setFacultyFilter(String faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  void setYearFilter(String year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setMaxDistance(double distance) {
    _maxDistance = distance;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedFaculty = 'All';
    _selectedYear = 'All';
    _maxDistance = 10.0;
    _searchQuery = '';
    notifyListeners();
  }
}
