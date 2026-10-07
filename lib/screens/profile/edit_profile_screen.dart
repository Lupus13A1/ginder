import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../widgets/bauhaus_dropdown.dart';
import '../../widgets/bauhaus_app_bar.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import '../../models/profile_interests.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../services/google_drive_service.dart';
import 'profile_preview_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final String? initialSection;

  const EditProfileScreen({super.key, this.initialSection});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _photosKey = GlobalKey();
  final GlobalKey _academicKey = GlobalKey();
  final GlobalKey _facultyKey = GlobalKey();
  final GlobalKey _majorKey = GlobalKey();
  final GlobalKey _bioKey = GlobalKey();
  final GlobalKey _activitiesKey = GlobalKey();
  final GlobalKey _lifestyleKey = GlobalKey();
  final GlobalKey _anthemKey = GlobalKey();
  final GlobalKey _hangoutKey = GlobalKey();

  String? _highlightedSection;
  Timer? _highlightTimer;

  late TextEditingController _usernameController;
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  late TextEditingController _anthemSongController;
  late TextEditingController _anthemArtistController;
  late TextEditingController _movieController;
  late TextEditingController _hangoutController;

  late String _selectedFaculty;
  late String _selectedYear;
  late Set<String> _selectedInterests;
  late ProfileInterests _profileInterests;
  late List<String> _photos;

  final List<String> _faculties = [
    'Faculty of Engineering',
    'Faculty of Architecture and Design',
    'Faculty of Information Technology and Digital Innovation (ITDI)',
    'Faculty of Applied Science',
    'Faculty of Technical Education',
    'College of Industrial Technology (CIT)',
    'Faculty of Business Administration',
    'Faculty of Business and Industrial Development (BID)',
    'Faculty of Business Administration and Service Industry (BAS)',
    'Faculty of Applied Arts',
    'Faculty of Agro-Industry',
    'Faculty of Industrial Technology and Management (FITM)',
    'Faculty of Engineering and Technology (Rayong)',
    'KMUTNB International College',
    'Thai-French Innovation Institute (TFII)',
    'Rayong / Prachinburi Campus Project',
  ];

  final List<String> _years = [
    'Year 1 (Freshman)',
    'Year 2 (Sophomore)',
    'Year 3 (Junior)',
    'Year 4 (Senior)',
    'Postgraduate',
  ];

  final List<String> _allInterests = [
    'Architecture',
    'Coding',
    'Specialty Coffee',
    'Badminton',
    'Film Photography',
    'Indie Rock',
    'Board Games',
    'Cats',
    'Cinema',
    'Matcha Latte',
    'Graphic Design',
    'Hackathons',
    'Gym & Fitness',
    'Ramen Quests',
    'Podcasts',
    'Vintage Thrift',
    'Astronomy',
    'Baking',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _usernameController = TextEditingController(
      text: user.name.isNotEmpty ? user.name : user.nickname,
    );
    _majorController = TextEditingController(
      text: user.major != '-' ? user.major : '',
    );
    _bioController = TextEditingController(text: user.bio);
    _anthemSongController = TextEditingController(text: user.anthemSong);
    _anthemArtistController = TextEditingController(text: user.anthemArtist);
    _movieController = TextEditingController(text: user.favoriteMovie);
    _hangoutController = TextEditingController(text: user.campusHangout);
    _selectedFaculty = _faculties.contains(user.faculty)
        ? user.faculty
        : _faculties.first;
    _selectedYear = _years.contains(user.year) ? user.year : _years.first;
    _selectedInterests = Set.from(user.interests);
    _profileInterests = user.profileInterests;
    _photos = List.from(user.photos);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final section =
          widget.initialSection ??
          (ModalRoute.of(context)?.settings.arguments as String?);
      if (section != null && section.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            _scrollToSection(section);
          }
        });
      }
    });
  }

  void _scrollToSection(String section) {
    final cleanSection = section.toLowerCase().trim();
    setState(() {
      _highlightedSection = cleanSection;
    });

    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _highlightedSection = null;
        });
      }
    });

    GlobalKey? targetKey;
    switch (cleanSection) {
      case 'photos':
        targetKey = _photosKey;
        break;
      case 'faculty':
        targetKey = _facultyKey;
        break;
      case 'academic':
        targetKey = _academicKey;
        break;
      case 'major':
        targetKey = _majorKey;
        break;
      case 'bio':
        targetKey = _bioKey;
        break;
      case 'activities':
        targetKey = _activitiesKey;
        break;
      case 'lifestyle':
      case 'interests':
        targetKey = _lifestyleKey;
        break;
      case 'anthem':
      case 'song':
        targetKey = _anthemKey;
        break;
      case 'hangout':
        targetKey = _hangoutKey;
        break;
    }

    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.12,
      );
    }
  }

  bool _isUploadingPhoto = false;
  int? _uploadingSlotIndex;

  Future<void> _handlePhotoUpload(int index) async {
    if (_isUploadingPhoto) return;

    final source = await GoogleDriveService.showImageSourceDialog(context);
    if (source == null) return;

    final picked = await GoogleDriveService.pickImage(source);
    if (picked == null) return;

    setState(() {
      _isUploadingPhoto = true;
      _uploadingSlotIndex = index;
    });

    final result = await GoogleDriveService.uploadImage(picked);

    if (!mounted) return;

    setState(() {
      _isUploadingPhoto = false;
      _uploadingSlotIndex = null;
    });

    if (result.isSuccess && result.url != null) {
      setState(() {
        if (index < _photos.length) {
          _photos[index] = result.url!;
        } else {
          _photos.add(result.url!);
        }
      });
      BauhausSnackBar.showSuccess(
        context,
        'PHOTO SAVED TO GOOGLE DRIVE! TAP CHECKMARK TO SAVE PROFILE.',
      );
    } else {
      BauhausSnackBar.showError(
        context,
        result.errorMessage ?? 'Upload to Google Drive failed',
      );
    }
  }

  void _removePhoto(int index) {
    if (_photos.length <= 1) {
      BauhausSnackBar.showWarning(
        context,
        'YOU MUST KEEP AT LEAST 1 PROFILE PHOTO',
      );
      return;
    }
    setState(() => _photos.removeAt(index));
  }

  void _reorderPhotos(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex >= _photos.length) return;

    setState(() {
      int targetIndex = newIndex;
      if (targetIndex >= _photos.length) {
        targetIndex = _photos.length - 1;
      }
      if (oldIndex != targetIndex) {
        final item = _photos.removeAt(oldIndex);
        _photos.insert(targetIndex, item);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _movePhoto(int currentIndex, int direction) {
    final targetIndex = currentIndex + direction;
    if (targetIndex < 0 || targetIndex >= _photos.length) return;
    _reorderPhotos(currentIndex, targetIndex);
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _usernameController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    _anthemSongController.dispose();
    _anthemArtistController.dispose();
    _movieController.dispose();
    _hangoutController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _getInterestValue(String key) {
    switch (key) {
      case 'datingFor':
        return _profileInterests.datingFor;
      case 'lookingFor':
        return _profileInterests.lookingFor;
      case 'languages':
        return _profileInterests.languages.isEmpty
            ? null
            : _profileInterests.languages.join(', ');
      case 'zodiac':
        return _profileInterests.zodiac;
      case 'education':
        return _profileInterests.education;
      case 'familyPlans':
        return _profileInterests.familyPlans;
      case 'communicationStyle':
        return _profileInterests.communicationStyle;
      case 'loveStyle':
        return _profileInterests.loveStyle;
      case 'bloodType':
        return _profileInterests.bloodType;
      case 'pets':
        return _profileInterests.pets;
      case 'drinking':
        return _profileInterests.drinking;
      case 'smoking':
        return _profileInterests.smoking;
      case 'workout':
        return _profileInterests.workout;
      case 'socialMedia':
        return _profileInterests.socialMedia;
      default:
        return null;
    }
  }

  void _updateInterestValue(String key, dynamic value) {
    setState(() {
      switch (key) {
        case 'datingFor':
          _profileInterests = _profileInterests.copyWith(
            datingFor: value as String?,
            clearDatingFor: value == null,
          );
          break;
        case 'lookingFor':
          _profileInterests = _profileInterests.copyWith(
            lookingFor: value as String?,
            clearLookingFor: value == null,
          );
          break;
        case 'languages':
          _profileInterests = _profileInterests.copyWith(
            languages: (value as List<String>?) ?? [],
          );
          break;
        case 'zodiac':
          _profileInterests = _profileInterests.copyWith(
            zodiac: value as String?,
            clearZodiac: value == null,
          );
          break;
        case 'education':
          _profileInterests = _profileInterests.copyWith(
            education: value as String?,
            clearEducation: value == null,
          );
          break;
        case 'familyPlans':
          _profileInterests = _profileInterests.copyWith(
            familyPlans: value as String?,
            clearFamilyPlans: value == null,
          );
          break;
        case 'communicationStyle':
          _profileInterests = _profileInterests.copyWith(
            communicationStyle: value as String?,
            clearCommunicationStyle: value == null,
          );
          break;
        case 'loveStyle':
          _profileInterests = _profileInterests.copyWith(
            loveStyle: value as String?,
            clearLoveStyle: value == null,
          );
          break;
        case 'bloodType':
          _profileInterests = _profileInterests.copyWith(
            bloodType: value as String?,
            clearBloodType: value == null,
          );
          break;
        case 'pets':
          _profileInterests = _profileInterests.copyWith(
            pets: value as String?,
            clearPets: value == null,
          );
          break;
        case 'drinking':
          _profileInterests = _profileInterests.copyWith(
            drinking: value as String?,
            clearDrinking: value == null,
          );
          break;
        case 'smoking':
          _profileInterests = _profileInterests.copyWith(
            smoking: value as String?,
            clearSmoking: value == null,
          );
          break;
        case 'workout':
          _profileInterests = _profileInterests.copyWith(
            workout: value as String?,
            clearWorkout: value == null,
          );
          break;
        case 'socialMedia':
          _profileInterests = _profileInterests.copyWith(
            socialMedia: value as String?,
            clearSocialMedia: value == null,
          );
          break;
      }
    });
  }

  void _openInterestPicker(InterestCategoryDefinition cat) {
    if (cat.isMultiSelect) {
      final selectedList = List<String>.from(_profileInterests.languages);
      BauhausBottomSheet.show(
        context: context,
        title: cat.label.toUpperCase(),
        headerColor: BauhausColors.primaryYellow,
        content: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select languages you speak or are learning:',
                  style: BauhausTextStyles.caption(
                    color: BauhausColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cat.options.map((option) {
                    final isSel = selectedList.contains(option);
                    return BauhausBadge(
                      label: option,
                      variant: isSel
                          ? BauhausBadgeVariant.yellow
                          : BauhausBadgeVariant.surface,
                      icon: isSel ? const Icon(Icons.check, size: 12) : null,
                      onTap: () {
                        setModalState(() {
                          if (isSel) {
                            selectedList.remove(option);
                          } else {
                            selectedList.add(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (selectedList.isNotEmpty)
                      Expanded(
                        child: BauhausButton.outline(
                          text: 'CLEAR',
                          height: 44,
                          onPressed: () {
                            setModalState(() {
                              selectedList.clear();
                            });
                          },
                        ),
                      ),
                    if (selectedList.isNotEmpty) const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: BauhausButton(
                        text: 'SAVE LANGUAGES',
                        height: 44,
                        variant: BauhausButtonVariant.primaryRed,
                        onPressed: () {
                          _updateInterestValue(cat.key, selectedList);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      );
    } else {
      final currentValue = _getInterestValue(cat.key);
      BauhausBottomSheet.show(
        context: context,
        title: cat.label.toUpperCase(),
        headerColor: BauhausColors.primaryBlue,
        headerTextColor: Colors.white,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select what describes you best:',
              style: BauhausTextStyles.caption(
                color: BauhausColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...cat.options.map((option) {
              final isSel = currentValue == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: isSel
                      ? BauhausColors.cardYellow
                      : BauhausColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSel
                          ? BauhausColors.primaryYellow
                          : BauhausColors.border,
                      width: 1.0,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(
                      option,
                      style: BauhausTextStyles.bodyMedium().copyWith(
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(
                            Icons.check_circle,
                            color: BauhausColors.primaryRed,
                            size: 20,
                          )
                        : null,
                    dense: true,
                    onTap: () {
                      _updateInterestValue(cat.key, option);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            }),
            if (currentValue != null) ...[
              const SizedBox(height: 10),
              BauhausButton.outline(
                text: 'REMOVE / DON\'T SHOW ON PROFILE',
                height: 42,
                onPressed: () {
                  _updateInterestValue(cat.key, null);
                  Navigator.of(context).pop();
                },
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
      );
    }
  }

  void _save() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      BauhausSnackBar.showWarning(context, 'Please enter username');
      return;
    }

    if (_photos.isEmpty) {
      BauhausSnackBar.showWarning(context, 'At least 1 profile photo required');
      return;
    }

    final auth = context.read<AuthProvider>();
    final updated = auth.currentUser.copyWith(
      name: username,
      nickname: username,
      bio: _bioController.text,
      major: _majorController.text.trim().isNotEmpty
          ? _majorController.text.trim()
          : '-',
      faculty: _selectedFaculty,
      year: _selectedYear,
      interests: _selectedInterests.toList(),
      activities: _selectedInterests.toList(),
      profileInterests: _profileInterests,
      anthemSong: _anthemSongController.text,
      anthemArtist: _anthemArtistController.text,
      favoriteMovie: _movieController.text,
      campusHangout: _hangoutController.text,
      photos: _photos,
    );

    auth.updateProfile(updated);
    BauhausSnackBar.showSuccess(context, 'CAMPUS PROFILE UPDATED SUCCESSFULLY');
    Navigator.of(context).pop();
  }

  void _previewDraft() {
    final auth = context.read<AuthProvider>();
    final draft = auth.currentUser.copyWith(
      name: _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : auth.currentUser.name,
      nickname: _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : auth.currentUser.nickname,
      faculty: _selectedFaculty,
      major: _majorController.text.trim().isNotEmpty
          ? _majorController.text.trim()
          : '-',
      year: _selectedYear,
      bio: _bioController.text.trim(),
      anthemSong: _anthemSongController.text.trim(),
      anthemArtist: _anthemArtistController.text.trim(),
      favoriteMovie: _movieController.text.trim(),
      campusHangout: _hangoutController.text.trim(),
      interests: _selectedInterests.toList(),
      profileInterests: _profileInterests,
      photos: _photos,
    );
    ProfilePreviewDialog.show(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppConfigProvider>();
    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: BauhausAppBar(
        title: 'EDIT PROFILE',
        showBrandMark: true,
        actions: [
          IconButton(
            tooltip: 'Preview',
            icon: Icon(
              Icons.visibility_outlined,
              color: BauhausColors.foreground,
            ),
            onPressed: _previewDraft,
          ),
          IconButton(
            tooltip: 'Save',
            icon: Icon(Icons.check, color: BauhausColors.foreground),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Photos Grid (6 slots)
            _SectionHighlightWrapper(
              sectionKey: _photosKey,
              isHighlighted: _highlightedSection == 'photos',
              badgeText: 'Upload Photos',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PROFILE PHOTOS (6 SLOTS)',
                          style: BauhausTextStyles.title(),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: BauhausColors.primaryRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8,
                          ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final isUploadingThis =
                            _isUploadingPhoto && _uploadingSlotIndex == index;
                        final hasPhoto = index < _photos.length;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            Widget content;
                            if (hasPhoto) {
                              content = Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: index == 0
                                        ? BauhausColors.primaryRed
                                        : BauhausColors.border,
                                    width: index == 0 ? 1.8 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      _photos[index],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 36,
                                                ),
                                              ),
                                    ),
                                    if (isUploadingThis)
                                      Container(
                                        color: Colors.black54,
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: BauhausColors.primaryYellow,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      ),
                                    // Slot Number Badge (Top-left)
                                    Positioned(
                                      top: 5,
                                      left: 5,
                                      child: index == 0
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: BauhausColors.primaryRed,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 9,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'MAIN',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 8,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              width: 18,
                                              height: 18,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: BauhausColors.surface,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: BauhausColors.border,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color:
                                                      BauhausColors.foreground,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                    ),
                                    // Remove Button (Top-right)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removePhoto(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: BauhausColors.primaryRed,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: BauhausColors.border,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Edit Button (Bottom-left)
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      child: GestureDetector(
                                        onTap: () => _handlePhotoUpload(index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BauhausColors.surface,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: BauhausColors.border,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.sync,
                                                size: 10,
                                                color: BauhausColors.foreground,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                'EDIT',
                                                style: BauhausTextStyles.badge()
                                                    .copyWith(fontSize: 7),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Quick Reorder Arrows (Bottom-right)
                                    if (_photos.length > 1)
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BauhausColors.surfaceDark
                                                .withValues(alpha: 0.85),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (index > 0)
                                                GestureDetector(
                                                  onTap: () =>
                                                      _movePhoto(index, -1),
                                                  child: const Icon(
                                                    Icons.arrow_back_ios_new,
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              if (index > 0 &&
                                                  index < _photos.length - 1)
                                                const SizedBox(width: 6),
                                              if (index < _photos.length - 1)
                                                GestureDetector(
                                                  onTap: () =>
                                                      _movePhoto(index, 1),
                                                  child: const Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            } else {
                              content = GestureDetector(
                                onTap: () => _handlePhotoUpload(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: BauhausColors.cardYellow.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: BauhausColors.borderSubtle,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isUploadingThis
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: BauhausColors.primaryRed,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: BauhausColors.muted,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: BauhausColors
                                                        .borderSubtle,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color:
                                                        BauhausColors.textMuted,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        BauhausColors.surface,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color:
                                                          BauhausColors.border,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.add_a_photo,
                                                    color: BauhausColors
                                                        .foreground,
                                                    size: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'ADD',
                                                  style:
                                                      BauhausTextStyles.badge()
                                                          .copyWith(
                                                            fontSize: 8,
                                                          ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            }

                            return DragTarget<int>(
                              onWillAcceptWithDetails: (details) =>
                                  details.data != index,
                              onAcceptWithDetails: (details) {
                                _reorderPhotos(details.data, index);
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isDropCandidate =
                                    candidateData.isNotEmpty;

                                Widget targetContent = content;

                                if (isDropCandidate) {
                                  targetContent = Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: BauhausColors.primaryBlue,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: BauhausColors.primaryBlue
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        content,
                                        Container(
                                          decoration: BoxDecoration(
                                            color: BauhausColors.cardBlue
                                                .withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    BauhausColors.primaryBlue,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'DROP HERE',
                                                style: BauhausTextStyles.badge(
                                                  color: Colors.white,
                                                ).copyWith(fontSize: 9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (hasPhoto) {
                                  return LongPressDraggable<int>(
                                    data: index,
                                    delay: const Duration(milliseconds: 150),
                                    hapticFeedbackOnStart: true,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      elevation: 12,
                                      child: Transform.rotate(
                                        angle: 0.05,
                                        child: Container(
                                          width: constraints.maxWidth,
                                          height: constraints.maxHeight,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: BauhausColors.primaryRed,
                                              width: 2.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.35,
                                                ),
                                                blurRadius: 16,
                                                offset: const Offset(4, 8),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  _photos[index],
                                                  fit: BoxFit.cover,
                                                ),
                                                Positioned(
                                                  top: 6,
                                                  left: 6,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: BauhausColors
                                                          .primaryYellow,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      border: Border.all(
                                                        color: BauhausColors
                                                            .border,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.drag_indicator,
                                                          size: 12,
                                                          color: BauhausColors
                                                              .foreground,
                                                        ),
                                                        const SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                          'MOVING',
                                                          style:
                                                              BauhausTextStyles.badge(
                                                                color: BauhausColors
                                                                    .foreground,
                                                              ).copyWith(
                                                                fontSize: 8,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.25,
                                      child: content,
                                    ),
                                    child: targetContent,
                                  );
                                } else {
                                  return targetContent;
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Personal Info Card
            _SectionHighlightWrapper(
              sectionKey: _academicKey,
              isHighlighted: _highlightedSection == 'academic',
              badgeText: 'Academic Info',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STUDENT INFORMATION',
                      style: BauhausTextStyles.title(),
                    ),
                    const SizedBox(height: 12),
                    BauhausTextField(
                      label: 'USERNAME',
                      hintText: 'Enter your username',
                      controller: _usernameController,
                      isRequired: true,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Faculty Dropdown
                    _SectionHighlightWrapper(
                      sectionKey: _facultyKey,
                      isHighlighted: _highlightedSection == 'faculty',
                      badgeText: 'Select Faculty',
                      borderRadius: 12,
                      child: BauhausDropdown<String>(
                        label: 'FACULTY',
                        isRequired: true,
                        indicatorColor: BauhausColors.primaryRed,
                        value: _selectedFaculty,
                        items: _faculties,
                        itemLabel: (f) => f,
                        menuMaxHeight: 280,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFaculty = val);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Major Input
                    _SectionHighlightWrapper(
                      sectionKey: _majorKey,
                      isHighlighted: _highlightedSection == 'major',
                      badgeText: 'Specify Major',
                      borderRadius: 12,
                      child: BauhausTextField(
                        label: 'MAJOR',
                        hintText: 'e.g. Computer Engineering (CPE)',
                        controller: _majorController,
                        indicatorColor: BauhausColors.primaryBlue,
                        prefixIcon: Icon(
                          Icons.school_outlined,
                          color: BauhausColors.foreground,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Year Dropdown
                    BauhausDropdown<String>(
                      label: 'STUDY YEAR',
                      isRequired: true,
                      indicatorColor: BauhausColors.primaryYellow,
                      value: _selectedYear,
                      items: _years,
                      itemLabel: (y) => y,
                      menuMaxHeight: 240,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedYear = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Bio Card
            _SectionHighlightWrapper(
              sectionKey: _bioKey,
              isHighlighted: _highlightedSection == 'bio',
              badgeText: 'Write Campus Bio',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CAMPUS BIO', style: BauhausTextStyles.title()),
                    const SizedBox(height: 8),
                    BauhausTextField(
                      hintText:
                          'Tell other students about yourself, what you study, or what you enjoy...',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Campus Activities & Passions (Separate from Interests)
            _SectionHighlightWrapper(
              sectionKey: _activitiesKey,
              isHighlighted: _highlightedSection == 'activities',
              badgeText: 'Campus Activities',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CAMPUS ACTIVITIES & PASSIONS',
                          style: BauhausTextStyles.title(),
                        ),
                        Text(
                          '${_selectedInterests.length} selected',
                          style: BauhausTextStyles.caption(
                            color: BauhausColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select university hobbies, clubs, and topics you care about',
                      style: BauhausTextStyles.caption(
                        color: BauhausColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _allInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return BauhausBadge(
                          label: interest,
                          variant: isSelected
                              ? BauhausBadgeVariant.yellow
                              : BauhausBadgeVariant.surface,
                          icon: isSelected
                              ? const Icon(Icons.check, size: 12)
                              : null,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedInterests.remove(interest);
                              } else {
                                _selectedInterests.add(interest);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 5. Structured Interests & Lifestyle (Tinder-style rows)
            _SectionHighlightWrapper(
              sectionKey: _lifestyleKey,
              isHighlighted:
                  _highlightedSection == 'lifestyle' ||
                  _highlightedSection == 'interests',
              badgeText: 'Lifestyle & Habits',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INTERESTS & LIFESTYLE',
                          style: BauhausTextStyles.title(),
                        ),
                        Text(
                          '${_profileInterests.displayItems.length}/14 set',
                          style: BauhausTextStyles.caption(
                            color: BauhausColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure your dating intent, lifestyle, zodiac, habits & more',
                      style: BauhausTextStyles.caption(
                        color: BauhausColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...ProfileInterests.categories.map((cat) {
                      final displayVal = _getInterestValue(cat.key);
                      final hasVal =
                          displayVal != null && displayVal.isNotEmpty;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _openInterestPicker(cat),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 6,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 20,
                                    color: hasVal
                                        ? BauhausColors.primaryBlue
                                        : BauhausColors.foreground,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    cat.label,
                                    style: BauhausTextStyles.title().copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      hasVal ? displayVal : 'Select',
                                      textAlign: TextAlign.end,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: hasVal
                                          ? BauhausTextStyles.bodyMedium(
                                              color: BauhausColors.primaryBlue,
                                            ).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            )
                                          : BauhausTextStyles.bodyMedium(
                                              color: BauhausColors.textMuted,
                                            ).copyWith(fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: hasVal
                                        ? BauhausColors.primaryBlue
                                        : BauhausColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(height: 1, color: BauhausColors.borderSubtle),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 6. Anthems & Favorites (with hintText placeholders)
            _SectionHighlightWrapper(
              sectionKey: _anthemKey,
              isHighlighted:
                  _highlightedSection == 'anthem' ||
                  _highlightedSection == 'song',
              badgeText: 'Campus Anthem',
              child: BauhausCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANTHEM & CAMPUS VIBES',
                      style: BauhausTextStyles.title(),
                    ),
                    const SizedBox(height: 10),
                    BauhausTextField(
                      label: 'FAVORITE SONG',
                      hintText: 'e.g. Sparks, About You, Midnight City',
                      controller: _anthemSongController,
                    ),
                    const SizedBox(height: 8),
                    BauhausTextField(
                      label: 'ARTIST',
                      hintText: 'e.g. Coldplay, The 1975, M83',
                      controller: _anthemArtistController,
                    ),
                    const SizedBox(height: 8),
                    BauhausTextField(
                      label: 'FAVORITE MOVIE',
                      hintText:
                          'e.g. Interstellar, La La Land, Good Will Hunting',
                      controller: _movieController,
                    ),
                    const SizedBox(height: 8),
                    _SectionHighlightWrapper(
                      sectionKey: _hangoutKey,
                      isHighlighted: _highlightedSection == 'hangout',
                      badgeText: 'Hangout Spot',
                      borderRadius: 12,
                      child: BauhausTextField(
                        label: 'CAMPUS HANGOUT SPOT',
                        hintText: 'e.g. Central Library 4th Floor, Arch Lawn',
                        controller: _hangoutController,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            BauhausButton(
              text: 'SAVE PROFILE CHANGES',
              isFullWidth: true,
              height: 52,
              variant: BauhausButtonVariant.primaryRed,
              onPressed: _save,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHighlightWrapper extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isHighlighted;
  final Widget child;
  final double borderRadius;
  final String? badgeText;

  const _SectionHighlightWrapper({
    required this.sectionKey,
    required this.isHighlighted,
    required this.child,
    this.borderRadius = 16,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: sectionKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: isHighlighted
              ? BauhausColors.primaryBlue.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isHighlighted
                ? BauhausColors.primaryBlue
                : Colors.transparent,
            width: isHighlighted ? 2.5 : 0.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: BauhausColors.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (isHighlighted && badgeText != null)
              Positioned(
                top: -12,
                right: 14,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryBlue,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badgeText!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
