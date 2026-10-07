import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../widgets/bauhaus_alert_banner.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/google_drive_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _bioController = TextEditingController();
  final _songController = TextEditingController();
  final _artistController = TextEditingController();
  final _movieController = TextEditingController();
  final _hangoutController = TextEditingController();

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

  final Set<String> _selectedInterests = {};

  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _photos = List.from(user.photos);
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
      BauhausSnackBar.showSuccess(context, 'PHOTO SAVED SUCCESSFULLY!');
    } else {
      BauhausSnackBar.showError(
        context,
        result.errorMessage ?? 'Upload failed',
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

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
    if (_photos.isEmpty) {
      BauhausSnackBar.showWarning(
        context,
        'Please upload at least 1 profile photo before continuing',
      );
      return;
    }

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
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppConfigProvider>();
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryYellow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
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
                  color: BauhausColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // 1. Photos Section
              BauhausCard(
                cornerBadge: BauhausCornerBadgeType.circleRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CAMPUS PHOTOS (${_photos.length}/4)',
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
                        BauhausBadge(
                          label: _photos.isEmpty ? 'REQUIRED 1+' : 'MAIN PHOTO',
                          variant: _photos.isEmpty
                              ? BauhausBadgeVariant.warning
                              : BauhausBadgeVariant.success,
                        ),
                      ],
                    ),
                    if (_photos.isEmpty) ...[
                      const SizedBox(height: 8),
                      const BauhausAlertBanner(
                        severity: BauhausAlertSeverity.warning,
                        message:
                            'Please upload at least 1 profile photo before proceeding',
                        title: 'REQUIRED PHOTO',
                      ),
                    ],
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                      children: List.generate(
                        4,
                        (index) => index < _photos.length
                            ? _buildPhotoSlot(index)
                            : _buildEmptySlot(index),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Bio Section
              BauhausCard(
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
                            prefixIcon: Icon(
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
                      prefixIcon: Icon(
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
                      prefixIcon: Icon(
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
    final isUploadingThis = _isUploadingPhoto && _uploadingSlotIndex == index;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: BauhausColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BauhausColors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
          if (isUploadingThis)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: BauhausColors.primaryYellow,
                  strokeWidth: 3,
                ),
              ),
            ),
          // Delete button on top right
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: BauhausColors.primaryRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: BauhausColors.border, width: 1.0),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
          // Change photo button on bottom left
          Positioned(
            bottom: 6,
            left: 6,
            child: GestureDetector(
              onTap: () => _handlePhotoUpload(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BauhausColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: BauhausColors.border, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 11, color: BauhausColors.foreground),
                    const SizedBox(width: 3),
                    Text(
                      'CHANGE',
                      style: BauhausTextStyles.badge().copyWith(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Checkmark badge on bottom right
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: BauhausColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: BauhausColors.border, width: 1.0),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(int index) {
    final isUploadingThis = _isUploadingPhoto && _uploadingSlotIndex == index;

    return GestureDetector(
      onTap: () => _handlePhotoUpload(index),
      child: Container(
        decoration: BoxDecoration(
          color: BauhausColors.cardYellow.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BauhausColors.borderSubtle,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: isUploadingThis
            ? const Center(
                child: CircularProgressIndicator(
                  color: BauhausColors.primaryRed,
                  strokeWidth: 3,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BauhausColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      Icons.add_a_photo,
                      color: BauhausColors.foreground,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ADD PHOTO',
                    style: BauhausTextStyles.badge(
                      color: BauhausColors.textSecondary,
                    ).copyWith(fontSize: 9),
                  ),
                  Text(
                    'TO DRIVE',
                    style: BauhausTextStyles.badge(
                      color: BauhausColors.primaryBlue,
                    ).copyWith(fontSize: 7),
                  ),
                ],
              ),
      ),
    );
  }
}
