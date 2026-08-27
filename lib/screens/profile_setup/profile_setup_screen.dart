import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../providers/auth_provider.dart';
import '../main_nav_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioController = TextEditingController(
    text:
        'Obsessed with modernist grid layouts, Brutalism, espresso shots, and urban exploration. Looking for study partners and concert buddies.',
  );
  final _songController = TextEditingController(text: 'Blue Monday');
  final _artistController = TextEditingController(text: 'New Order');
  final _movieController = TextEditingController(text: 'Metropolis (1927)');
  final _hangoutController = TextEditingController(
    text: 'Central Library 4th Floor & Arch Workshop',
  );

  final List<String> _availableInterests = [
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

  final Set<String> _selectedInterests = {
    'Architecture',
    'Indie Rock',
    'Matcha Latte',
    'Coding',
    'Board Games',
    'Specialty Coffee',
  };

  final List<String> _photos = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=700&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=700&auto=format&fit=crop&q=80',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _songController.dispose();
    _artistController.dispose();
    _movieController.dispose();
    _hangoutController.dispose();
    super.dispose();
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _saveProfile() {
    context.read<AuthProvider>().completeProfileSetup(
      bio: _bioController.text,
      interests: _selectedInterests.toList(),
      anthemSong: _songController.text,
      anthemArtist: _artistController.text,
      favoriteMovie: _movieController.text,
      campusHangout: _hangoutController.text,
      photos: _photos,
    );

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GeometricBrandMark(size: 14, spacing: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryYellow,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'STEP 2 OF 2',
                      style: BauhausTextStyles.badge(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text('PROFILE\nSETUP', style: BauhausTextStyles.hero()),
              const SizedBox(height: 8),
              Text(
                'Showcase your personality, campus spots, and favorite anthems to find your ideal university match.',
                style: BauhausTextStyles.bodyMedium(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // 1. Photos Section
              BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                cornerBadge: BauhausCornerBadgeType.circleRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CAMPUS PHOTOS (2/4)',
                          style: BauhausTextStyles.title(),
                        ),
                        const BauhausBadge(
                          label: 'MAIN PHOTO',
                          variant: BauhausBadgeVariant.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                      children: [
                        _buildPhotoSlot(0),
                        _buildPhotoSlot(1),
                        _buildEmptySlot(2),
                        _buildEmptySlot(3),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Bio Section
              BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMPUS BIO / TAGLINE',
                      style: BauhausTextStyles.title(),
                    ),
                    const SizedBox(height: 8),
                    BauhausTextField(
                      hintText:
                          'Share what you study, your weekend vibe, or what you are looking for...',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Interests Chips Section
              BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                cornerBadge: BauhausCornerBadgeType.triangleYellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CAMPUS INTERESTS',
                          style: BauhausTextStyles.title(),
                        ),
                        Text(
                          '${_selectedInterests.length} SELECTED',
                          style: BauhausTextStyles.badge(
                            color: BauhausColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableInterests.map((interest) {
                        final isSelected = _selectedInterests.contains(
                          interest,
                        );
                        return BauhausBadge(
                          label: interest,
                          isPill: true,
                          variant: isSelected
                              ? BauhausBadgeVariant.yellow
                              : BauhausBadgeVariant.surface,
                          onTap: () => _toggleInterest(interest),
                          icon: isSelected
                              ? const Icon(Icons.check, size: 14)
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. University Vibes & Anthem
              BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                cornerBadge: BauhausCornerBadgeType.squareBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAMPUS VIBES & ANTHEM',
                      style: BauhausTextStyles.title(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: BauhausTextField(
                            label: 'FAVORITE ANTHEM SONG',
                            hintText: 'Blue Monday',
                            controller: _songController,
                            prefixIcon: const Icon(
                              Icons.music_note,
                              color: BauhausColors.foreground,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: BauhausTextField(
                            label: 'ARTIST',
                            hintText: 'New Order',
                            controller: _artistController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BauhausTextField(
                      label: 'FAVORITE MOVIE',
                      hintText: 'Metropolis (1927)',
                      controller: _movieController,
                      prefixIcon: const Icon(
                        Icons.movie,
                        color: BauhausColors.foreground,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BauhausTextField(
                      label: 'FAVORITE CAMPUS HANGOUT',
                      hintText: 'Central Library 4th Floor',
                      controller: _hangoutController,
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: BauhausColors.foreground,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Launch Button
              BauhausButton(
                text: 'COMPLETE & LAUNCH GINDER',
                isFullWidth: true,
                height: 54,
                variant: BauhausButtonVariant.primaryRed,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(int index) {
    return Container(
      decoration: BoxDecoration(
        color: BauhausColors.surface,
        border: Border.all(color: BauhausColors.border, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: BauhausColors.border,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _photos[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.person, size: 40)),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: BauhausColors.primaryRed,
                shape: BoxShape.circle,
                border: Border.all(color: BauhausColors.border, width: 1.5),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    return Container(
      decoration: BoxDecoration(
        color: BauhausColors.cardYellow.withAlpha(80),
        border: Border.all(
          color: BauhausColors.border,
          width: 2.0,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BauhausColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: BauhausColors.border, width: 1.5),
            ),
            child: const Icon(
              Icons.add,
              color: BauhausColors.foreground,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ADD PHOTO',
            style: BauhausTextStyles.badge(
              color: Colors.grey.shade700,
            ).copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
