import 'package:flutter/foundation.dart';
import '../models/student_profile.dart';

enum SwipeDirection { left, right, up }

class DiscoverProvider extends ChangeNotifier {
  List<StudentProfile> _profiles = [];
  final List<StudentProfile> _passedProfiles = [];
  final List<StudentProfile> _likedProfiles = [];
  final List<StudentProfile> _superLikedProfiles = [];
  StudentProfile? _lastSwipedProfile;
  SwipeDirection? _lastSwipeDirection;

  // Filters
  String _selectedFaculty = 'All';
  String _selectedYear = 'All';
  double _maxDistance = 10.0;
  String _searchQuery = '';

  StudentProfile? _currentMatchProfile;

  DiscoverProvider() {
    resetDeck();
  }

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

  void resetDeck() {
    _profiles = List.from(StudentProfile.sampleProfiles);
    _passedProfiles.clear();
    _likedProfiles.clear();
    _superLikedProfiles.clear();
    _lastSwipedProfile = null;
    _lastSwipeDirection = null;
    _currentMatchProfile = null;
    notifyListeners();
  }

  bool likeCurrent() {
    if (!hasCards) return false;
    final card = currentCard!;
    _profiles.remove(card);
    _likedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.right;

    // Simulate match on certain students (e.g. Pim, Mei, Grace)
    final isMatch =
        card.id == 'student_1' ||
        card.id == 'student_3' ||
        card.id == 'student_5';
    if (isMatch) {
      _currentMatchProfile = card;
    }
    notifyListeners();
    return isMatch;
  }

  void passCurrent() {
    if (!hasCards) return;
    final card = currentCard!;
    _profiles.remove(card);
    _passedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.left;
    notifyListeners();
  }

  bool superLikeCurrent() {
    if (!hasCards) return false;
    final card = currentCard!;
    _profiles.remove(card);
    _superLikedProfiles.add(card);
    _lastSwipedProfile = card;
    _lastSwipeDirection = SwipeDirection.up;

    // Superlike triggers match directly
    _currentMatchProfile = card;
    notifyListeners();
    return true;
  }

  void rewind() {
    if (_lastSwipedProfile == null) return;
    _profiles.insert(0, _lastSwipedProfile!);
    if (_lastSwipeDirection == SwipeDirection.right) {
      _likedProfiles.remove(_lastSwipedProfile);
    } else if (_lastSwipeDirection == SwipeDirection.left) {
      _passedProfiles.remove(_lastSwipedProfile);
    } else if (_lastSwipeDirection == SwipeDirection.up) {
      _superLikedProfiles.remove(_lastSwipedProfile);
    }
    _lastSwipedProfile = null;
    _lastSwipeDirection = null;
    notifyListeners();
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
