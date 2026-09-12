import 'package:flutter/material.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/student_profile.dart';
import '../../routes/app_routes.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedVibe = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<StudentProfile> _allProfiles = [];
  bool _isLoading = true;
  final DatabaseService _db = DatabaseService();

  final List<Map<String, dynamic>> _campusVibes = [
    {
      'id': 'ALL',
      'label': 'ALL CAMPUS',
      'color': BauhausColors.foreground,
      'icon': Icons.apps,
    },
    {
      'id': 'STUDY',
      'label': 'LIBRARY BUDDIES',
      'color': BauhausColors.primaryRed,
      'icon': Icons.menu_book,
    },
    {
      'id': 'TECH',
      'label': 'CODING & HACKS',
      'color': BauhausColors.primaryBlue,
      'icon': Icons.code,
    },
    {
      'id': 'DESIGN',
      'label': 'DESIGN CREATIVES',
      'color': BauhausColors.primaryYellow,
      'icon': Icons.palette,
    },
    {
      'id': 'MUSIC',
      'label': 'INDIE MUSIC & VINYL',
      'color': BauhausColors.primaryRed,
      'icon': Icons.headphones,
    },
    {
      'id': 'SPORTS',
      'label': 'CAMPUS ATHLETES',
      'color': BauhausColors.primaryBlue,
      'icon': Icons.fitness_center,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id';
    final profiles = await _db.getDiscoverProfiles(currentUserId);
    if (mounted) {
      setState(() {
        _allProfiles = profiles;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentProfile> _getFilteredProfiles() {
    return _allProfiles.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match =
            p.name.toLowerCase().contains(q) ||
            p.nickname.toLowerCase().contains(q) ||
            p.faculty.toLowerCase().contains(q) ||
            p.interests.any((i) => i.toLowerCase().contains(q));
        if (!match) return false;
      }

      if (_selectedVibe == 'TECH') {
        return p.faculty.contains('Engineering') ||
            p.interests.contains('Coding');
      } else if (_selectedVibe == 'DESIGN') {
        return p.faculty.contains('Architecture') ||
            p.faculty.contains('Arts') ||
            p.interests.contains('Modern Art');
      } else if (_selectedVibe == 'MUSIC') {
        return p.interests.contains('Indie Rock') ||
            p.interests.contains('Spotify Playlists') ||
            p.interests.contains('Acoustic Guitar');
      } else if (_selectedVibe == 'SPORTS') {
        return p.interests.contains('Badminton') ||
            p.interests.contains('Running') ||
            p.interests.contains('Gym Workout');
      } else if (_selectedVibe == 'STUDY') {
        return p.faculty.contains('Medicine') ||
            p.faculty.contains('Science') ||
            p.interests.contains('Astronomy');
      }
      return true;
    }).toList();
  }

  void _showStudentDetails(StudentProfile profile) {
    BauhausBottomSheet.show(
      context: context,
      title: '${profile.nickname.toUpperCase()} (EXPLORE)',
      headerColor: BauhausColors.primaryYellow,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BauhausAvatar(
                imageUrl: profile.photos.isNotEmpty
                    ? profile.photos.first
                    : null,
                initial: profile.nickname[0],
                size: 70,
                isCircle: false,
                backgroundColor: BauhausColors.primaryBlue,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: BauhausTextStyles.headlineMedium(),
                    ),
                    const SizedBox(height: 4),
                    BauhausBadge(
                      label: profile.faculty,
                      variant: BauhausBadgeVariant.red,
                    ),
                    const SizedBox(height: 4),
                    Text(profile.major, style: BauhausTextStyles.bodyMedium()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('CAMPUS BIO', style: BauhausTextStyles.badge()),
          const SizedBox(height: 4),
          Text(profile.bio, style: BauhausTextStyles.bodyMedium()),
          const SizedBox(height: 16),
          Text('COMMON INTERESTS & HOBBIES', style: BauhausTextStyles.badge()),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.interests
                .map(
                  (i) => BauhausBadge(
                    label: i,
                    variant: BauhausBadgeVariant.surface,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop(); // Close bottom sheet

                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? 'my_user_id';

                    // Optimistic UI update
                    setState(() {
                      _allProfiles.removeWhere((p) => p.id == profile.id);
                    });

                    // Show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sent like to ${profile.nickname}!'),
                        backgroundColor: BauhausColors.primaryRed,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Send like to DB
                    final isMatch = await _db.swipeRight(
                      currentUserId,
                      profile.id,
                    );

                    if (isMatch && mounted) {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.matchFound, arguments: profile);
                    }
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryRed,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: BauhausColors.border,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'SEND LIKE TO ${profile.nickname.toUpperCase()}',
                      style: BauhausTextStyles.button(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _getFilteredProfiles();

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 3.0),
                ),
              ),
              child: Row(
                children: [
                  const GeometricBrandMark(size: 13, spacing: 5),
                  const SizedBox(width: 10),
                  Text(
                    'EXPLORE CAMPUS',
                    style: BauhausTextStyles.headlineMedium().copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: BauhausTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  hintText: 'Search by faculty, interest, or name...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BauhausColors.foreground,
                  ),
                  filled: true,
                  fillColor: BauhausColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(
                      color: BauhausColors.border,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            // Campus Vibes Horizontal Selector
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _campusVibes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final vibe = _campusVibes[index];
                  final isSelected = _selectedVibe == vibe['id'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedVibe = vibe['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? vibe['color'] as Color
                            : BauhausColors.surface,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: BauhausColors.border,
                                  offset: Offset(2, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            vibe['icon'] as IconData,
                            size: 14,
                            color: isSelected
                                ? (vibe['color'] == BauhausColors.primaryYellow
                                      ? BauhausColors.foreground
                                      : Colors.white)
                                : BauhausColors.foreground,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vibe['label'] as String,
                            style: BauhausTextStyles.badge(
                              color: isSelected
                                  ? (vibe['color'] ==
                                            BauhausColors.primaryYellow
                                        ? BauhausColors.foreground
                                        : Colors.white)
                                  : BauhausColors.foreground,
                            ).copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 2-Column Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: BauhausColors.primaryRed,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProfiles,
                      color: BauhausColors.primaryRed,
                      child: profiles.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                ),
                                Center(
                                  child: Text(
                                    'No students found for this vibe.\nPull down to refresh.',
                                    textAlign: TextAlign.center,
                                    style: BauhausTextStyles.bodyMedium(),
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: profiles.length,
                              itemBuilder: (context, index) {
                                final student = profiles[index];
                                return GestureDetector(
                                  onTap: () => _showStudentDetails(student),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: BauhausColors.surface,
                                      borderRadius: BorderRadius.zero,
                                      border: Border.all(
                                        color: BauhausColors.border,
                                        width: 2.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: BauhausColors.border,
                                          offset: Offset(3, 3),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Photo
                                        Expanded(
                                          flex: 6,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                student.photos.isNotEmpty
                                                    ? student.photos.first
                                                    : '',
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: BauhausColors
                                                          .cardYellow,
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                              Positioned(
                                                top: 6,
                                                left: 6,
                                                child: BauhausBadge(
                                                  label:
                                                      '${student.distanceKm} KM',
                                                  variant: BauhausBadgeVariant
                                                      .yellow,
                                                  fontSize: 8,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 2,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Info Strip
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: BauhausColors.surface,
                                            border: Border(
                                              top: BorderSide(
                                                color: BauhausColors.border,
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${student.nickname}, ${student.age}'
                                                    .toUpperCase(),
                                                style: BauhausTextStyles.title()
                                                    .copyWith(fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                student.faculty
                                                    .split(' ')
                                                    .first,
                                                style:
                                                    BauhausTextStyles.caption(
                                                      color: BauhausColors
                                                          .primaryRed,
                                                    ).copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
