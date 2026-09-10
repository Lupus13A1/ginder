import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../widgets/bauhaus_app_bar.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  late TextEditingController _majorController;
  late TextEditingController _anthemSongController;
  late TextEditingController _anthemArtistController;
  late TextEditingController _movieController;
  late TextEditingController _hangoutController;

  late String _selectedFaculty;
  late String _selectedYear;
  late Set<String> _selectedInterests;
  late List<String> _photos;

  final List<String> _faculties = [
    'Architecture & Design',
    'Engineering',
    'Communication Arts',
    'Medicine & Health',
    'Business Administration',
    'Science & Tech',
    'Faculty of Arts',
    'Faculty of Law',
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
    _nameController = TextEditingController(text: user.name);
    _nicknameController = TextEditingController(text: user.nickname);
    _bioController = TextEditingController(text: user.bio);
    _majorController = TextEditingController(text: user.major);
    _anthemSongController = TextEditingController(text: user.anthemSong);
    _anthemArtistController = TextEditingController(text: user.anthemArtist);
    _movieController = TextEditingController(text: user.favoriteMovie);
    _hangoutController = TextEditingController(text: user.campusHangout);
    _selectedFaculty = user.faculty;
    _selectedYear = user.year;
    _selectedInterests = Set.from(user.interests);
    _photos = List.from(user.photos);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
    _majorController.dispose();
    _anthemSongController.dispose();
    _anthemArtistController.dispose();
    _movieController.dispose();
    _hangoutController.dispose();
    super.dispose();
  }

  void _save() {
    final auth = context.read<AuthProvider>();
    final updated = auth.currentUser.copyWith(
      name: _nameController.text,
      nickname: _nicknameController.text,
      bio: _bioController.text,
      major: _majorController.text,
      faculty: _selectedFaculty,
      year: _selectedYear,
      interests: _selectedInterests.toList(),
      anthemSong: _anthemSongController.text,
      anthemArtist: _anthemArtistController.text,
      favoriteMovie: _movieController.text,
      campusHangout: _hangoutController.text,
      photos: _photos,
    );

    auth.updateProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CAMPUS PROFILE UPDATED SUCCESSFULLY'),
        backgroundColor: BauhausColors.primaryRed,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: BauhausAppBar(
        title: 'EDIT PROFILE',
        showBrandMark: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: BauhausColors.foreground),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Photos Grid (6 slots)
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              cornerBadge: BauhausCornerBadgeType.circleRed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROFILE PHOTOS (6 SLOTS)',
                    style: BauhausTextStyles.title(),
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
                      if (index < _photos.length) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: BauhausColors.border,
                              width: 2.0,
                            ),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(_photos[index], fit: BoxFit.cover),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_photos.length > 1) {
                                      setState(() => _photos.removeAt(index));
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    color: BauhausColors.primaryRed,
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _photos.add(
                                'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=700&auto=format&fit=crop&q=80',
                              );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: BauhausColors.cardYellow.withAlpha(90),
                              border: Border.all(
                                color: BauhausColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: BauhausColors.foreground,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Personal Info Card
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              cornerBadge: BauhausCornerBadgeType.squareBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STUDENT INFORMATION', style: BauhausTextStyles.title()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: BauhausTextField(
                          label: 'FULL NAME',
                          controller: _nameController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: BauhausTextField(
                          label: 'NICKNAME',
                          controller: _nicknameController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BauhausTextField(
                    label: 'MAJOR / FIELD',
                    controller: _majorController,
                  ),
                  const SizedBox(height: 12),

                  // Faculty Dropdown
                  Text('FACULTY', style: BauhausTextStyles.badge()),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: BauhausColors.surface,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _faculties.contains(_selectedFaculty)
                            ? _selectedFaculty
                            : _faculties.first,
                        isExpanded: true,
                        items: _faculties
                            .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedFaculty = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Year Dropdown
                  Text('STUDY YEAR', style: BauhausTextStyles.badge()),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: BauhausColors.surface,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _years.contains(_selectedYear)
                            ? _selectedYear
                            : _years[2],
                        isExpanded: true,
                        items: _years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedYear = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Bio Card
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CAMPUS BIO', style: BauhausTextStyles.title()),
                  const SizedBox(height: 8),
                  BauhausTextField(controller: _bioController, maxLines: 3),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Interests Selector
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              cornerBadge: BauhausCornerBadgeType.triangleYellow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERESTS & ACTIVITIES',
                    style: BauhausTextStyles.title(),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
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

            const SizedBox(height: 16),

            // 5. Anthems & Favorites
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
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
                    controller: _anthemSongController,
                  ),
                  const SizedBox(height: 8),
                  BauhausTextField(
                    label: 'ARTIST',
                    controller: _anthemArtistController,
                  ),
                  const SizedBox(height: 8),
                  BauhausTextField(
                    label: 'FAVORITE MOVIE',
                    controller: _movieController,
                  ),
                  const SizedBox(height: 8),
                  BauhausTextField(
                    label: 'CAMPUS HANGOUT SPOT',
                    controller: _hangoutController,
                  ),
                ],
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
