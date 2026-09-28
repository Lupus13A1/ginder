import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../routes/app_routes.dart';
import '../safety/report_dialog.dart';

import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_dialog.dart';
import '../../widgets/bauhaus_snackbar.dart';

/// Full-screen, Tinder-style comprehensive profile view
class ProfilePreviewDialog extends StatefulWidget {
  final StudentProfile profile;
  final bool? isSelf;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onSuperLike;
  final VoidCallback? onChat;
  final VoidCallback? onUnmatchedOrBlocked;

  const ProfilePreviewDialog({
    super.key,
    required this.profile,
    this.isSelf,
    this.onLike,
    this.onPass,
    this.onSuperLike,
    this.onChat,
    this.onUnmatchedOrBlocked,
  });

  static void show(
    BuildContext context,
    StudentProfile profile, {
    bool? isSelf,
    VoidCallback? onLike,
    VoidCallback? onPass,
    VoidCallback? onSuperLike,
    VoidCallback? onChat,
    VoidCallback? onUnmatchedOrBlocked,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => ProfilePreviewDialog(
        profile: profile,
        isSelf: isSelf,
        onLike: onLike,
        onPass: onPass,
        onSuperLike: onSuperLike,
        onChat: onChat,
        onUnmatchedOrBlocked: onUnmatchedOrBlocked,
      ),
    );
  }

  @override
  State<ProfilePreviewDialog> createState() => _ProfilePreviewDialogState();
}

class _ProfilePreviewDialogState extends State<ProfilePreviewDialog> {
  int _activePhotoIndex = 0;
  bool _isInterestsExpanded = false;

  List<String> get _photos =>
      widget.profile.photos.isNotEmpty ? widget.profile.photos : [''];

  void _nextPhoto() {
    if (_photos.length <= 1) return;
    setState(() {
      _activePhotoIndex = (_activePhotoIndex + 1) % _photos.length;
    });
  }

  void _prevPhoto() {
    if (_photos.length <= 1) return;
    setState(() {
      _activePhotoIndex =
          (_activePhotoIndex - 1 + _photos.length) % _photos.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final interests = profile.profileInterests;
    final photoUrl = _photos[_activePhotoIndex.clamp(0, _photos.length - 1)];

    final auth = context.read<AuthProvider>();
    final myUid = auth.firebaseUserId ?? auth.currentUser.id;
    final isCurrentUser = widget.isSelf ?? (widget.profile.id == myUid);

    return Container(
      decoration: BoxDecoration(
        color: BauhausColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Sticky Header (Name, Age + Down Button) ──────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: BauhausColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                bottom: BorderSide(color: BauhausColors.border, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const GeometricBrandMark(size: 10, spacing: 4),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${profile.name}, ${profile.age}'.toUpperCase(),
                          style: BauhausTextStyles.headlineLarge().copyWith(
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (profile.isVerifiedStudent) ...[
                        const SizedBox(width: 8),
                        const BauhausBadge(
                          label: 'VERIFIED',
                          variant: BauhausBadgeVariant.info,
                          icon: Icon(Icons.verified, size: 14),
                        ),
                      ],
                    ],
                  ),
                ),
                // Down-arrow dismiss button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: BauhausColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Body with Photo & Cards ──────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Large Cover Photo with Story Dash Bars
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    height: 480,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: const Color(0xFFE5E7EB),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                          ),

                          // Left & Right Tap Zones
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: _prevPhoto,
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: _nextPhoto,
                                ),
                              ),
                            ],
                          ),

                          // Story Dash Bars
                          if (_photos.length > 1)
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: Row(
                                children: List.generate(_photos.length, (idx) {
                                  final isCurrent = idx == _activePhotoIndex;
                                  return Expanded(
                                    child: Container(
                                      height: 4.0,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrent
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: 0.4,
                                              ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Dating Goal Card (Only if data exists)
                  if ((interests.datingFor?.isNotEmpty == true) ||
                      (interests.familyPlans?.isNotEmpty == true))
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: BauhausCard(
                        cornerBadge: BauhausCornerBadgeType.circleRed,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 18,
                                  color: BauhausColors.foreground,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DATING GOAL',
                                  style: BauhausTextStyles.title().copyWith(
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            if (interests.datingFor?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Text(
                                interests.datingFor!,
                                style: BauhausTextStyles.headlineMedium(),
                              ),
                            ],
                            if (interests.familyPlans?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              BauhausBadge(
                                label: interests.familyPlans!,
                                variant: BauhausBadgeVariant.muted,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // 3. About Me / Bio Card
                  if (profile.bio.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: BauhausCard.yellow(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '“',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: BauhausColors.foreground,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'ABOUT ME',
                                  style: BauhausTextStyles.title().copyWith(
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              profile.bio.trim(),
                              style: BauhausTextStyles.bodyMedium(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 4. General Info Card
                  Builder(
                    builder: (context) {
                      final generalInfoRows = <Widget>[];

                      if (profile.faculty.trim().isNotEmpty) {
                        generalInfoRows.add(
                          _buildInfoRow(
                            icon: Icons.school_outlined,
                            text: profile.faculty.trim(),
                          ),
                        );
                      }

                      final eduDetails = [
                        if (profile.year.trim().isNotEmpty) profile.year.trim(),
                        if (profile.major.trim().isNotEmpty &&
                            profile.major.trim() != '-')
                          profile.major.trim(),
                      ].join(' • ');
                      if (eduDetails.isNotEmpty) {
                        generalInfoRows.add(
                          _buildInfoRow(
                            icon: Icons.book_outlined,
                            text: eduDetails,
                          ),
                        );
                      }

                      if (profile.campusHangout.trim().isNotEmpty) {
                        generalInfoRows.add(
                          _buildInfoRow(
                            icon: Icons.home_outlined,
                            text: profile.campusHangout.trim(),
                          ),
                        );
                      }

                      if (profile.isVerifiedStudent) {
                        generalInfoRows.add(
                          _buildInfoRow(
                            icon: Icons.verified_user_outlined,
                            text: 'Verified university student',
                          ),
                        );
                      }

                      if (interests.lookingFor?.isNotEmpty == true) {
                        generalInfoRows.add(
                          _buildInfoRow(
                            icon: Icons.search,
                            text: 'Looking for ${interests.lookingFor}',
                          ),
                        );
                      }

                      if (generalInfoRows.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final separatedRows = <Widget>[];
                      for (int i = 0; i < generalInfoRows.length; i++) {
                        if (i > 0) separatedRows.add(_buildDivider());
                        separatedRows.add(generalInfoRows[i]);
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: BauhausCard(
                          cornerBadge: BauhausCornerBadgeType.squareBlue,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 18,
                                    color: BauhausColors.foreground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GENERAL INFO',
                                    style: BauhausTextStyles.title().copyWith(
                                      color: BauhausColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...separatedRows,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 5. More About Me Card
                  Builder(
                    builder: (context) {
                      final items = <Widget>[];

                      if (interests.education?.isNotEmpty == true) {
                        items.addAll([
                          _buildSectionHeader('EDUCATION'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.school_outlined,
                            text: interests.education!,
                          ),
                        ]);
                      }

                      if (interests.zodiac?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('ZODIAC'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.nights_stay_outlined,
                            text: interests.zodiac!,
                          ),
                        ]);
                      }

                      if (interests.languages.isNotEmpty) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('LANGUAGES'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.translate,
                            text: interests.languages.join(', '),
                          ),
                        ]);
                      }

                      if (interests.communicationStyle?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('COMMUNICATION STYLE'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.chat_bubble_outline,
                            text: interests.communicationStyle!,
                          ),
                        ]);
                      }

                      if (interests.loveStyle?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('LOVE STYLE'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.favorite_border,
                            text: interests.loveStyle!,
                          ),
                        ]);
                      }

                      if (interests.bloodType?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('BLOOD TYPE'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.water_drop_outlined,
                            text: interests.bloodType!,
                          ),
                        ]);
                      }

                      if (items.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: BauhausCard(
                          cornerBadge: BauhausCornerBadgeType.triangleYellow,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.label_outline,
                                    size: 18,
                                    color: BauhausColors.foreground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MORE ABOUT ME',
                                    style: BauhausTextStyles.title().copyWith(
                                      color: BauhausColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...items,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 6. Lifestyle Card
                  Builder(
                    builder: (context) {
                      final items = <Widget>[];

                      if (interests.workout?.isNotEmpty == true) {
                        items.addAll([
                          _buildSectionHeader('WORKOUT'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.fitness_center,
                            text: interests.workout!,
                          ),
                        ]);
                      }

                      if (interests.pets?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('PETS'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.pets,
                            text: interests.pets!,
                          ),
                        ]);
                      }

                      if (interests.drinking?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('DRINKING'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.local_bar,
                            text: interests.drinking!,
                          ),
                        ]);
                      }

                      if (interests.smoking?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('SMOKING'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.smoking_rooms,
                            text: interests.smoking!,
                          ),
                        ]);
                      }

                      if (interests.socialMedia?.isNotEmpty == true) {
                        if (items.isNotEmpty) {
                          items.add(const SizedBox(height: 14));
                        }
                        items.addAll([
                          _buildSectionHeader('SOCIAL MEDIA'),
                          const SizedBox(height: 4),
                          _buildIconText(
                            icon: Icons.share_outlined,
                            text: interests.socialMedia!,
                          ),
                        ]);
                      }

                      if (items.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: BauhausCard(
                          cornerBadge: BauhausCornerBadgeType.circleRed,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.loyalty_outlined,
                                    size: 18,
                                    color: BauhausColors.foreground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'LIFESTYLE',
                                    style: BauhausTextStyles.title().copyWith(
                                      color: BauhausColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ...items,
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 7. Interests Chips Card
                  if (profile.activities.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: BauhausCard(
                        cornerBadge: BauhausCornerBadgeType.triangleYellow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.interests_outlined,
                                  size: 18,
                                  color: BauhausColors.foreground,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'INTERESTS',
                                  style: BauhausTextStyles.title().copyWith(
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Builder(
                              builder: (context) {
                                final allChips = profile.activities;
                                final displayedChips = _isInterestsExpanded
                                    ? allChips
                                    : allChips.take(6).toList();

                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: displayedChips.map((chipText) {
                                    return BauhausBadge(
                                      label:
                                          '${_getEmojiForInterest(chipText)} $chipText',
                                      variant: BauhausBadgeVariant.surface,
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            if (profile.activities.length > 6) ...[
                              const SizedBox(height: 14),
                              Center(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _isInterestsExpanded =
                                        !_isInterestsExpanded;
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isInterestsExpanded
                                              ? 'Show less'
                                              : 'View all ${profile.activities.length}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: BauhausColors.foreground,
                                          ),
                                        ),
                                        Icon(
                                          _isInterestsExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: BauhausColors.foreground,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // 8. Campus Anthem Spotify Card
                  if (profile.anthemSong.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: BauhausCard.blue(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.music_note,
                                  size: 18,
                                  color: BauhausColors.foreground,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CAMPUS ANTHEM',
                                  style: BauhausTextStyles.title().copyWith(
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                // Album Artwork Thumbnail with Play Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade300,
                                    image: photoUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(photoUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.5,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.anthemSong.trim(),
                                        style:
                                            BauhausTextStyles.headlineMedium(),
                                      ),
                                      if (profile.anthemArtist
                                          .trim()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: const BoxDecoration(
                                                color:
                                                    BauhausColors.primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.music_note,
                                                size: 11,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                profile.anthemArtist.trim(),
                                                style:
                                                    BauhausTextStyles.bodyMedium()
                                                        .copyWith(
                                                          color: BauhausColors
                                                              .foreground,
                                                        ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (isCurrentUser)
                    // Bottom Action Buttons (Edit Profile shortcut)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BauhausButton(
                        text: 'EDIT PROFILE',
                        variant: BauhausButtonVariant.black,
                        isFullWidth: true,
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.editProfile);
                        },
                      ),
                    )
                  else ...[
                    // Interaction Buttons for viewing another student in Discover
                    if (widget.onLike != null ||
                        widget.onPass != null ||
                        widget.onSuperLike != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Pass (X)
                            _buildActionButton(
                              icon: Icons.close,
                              color: BauhausColors.surface,
                              iconColor: BauhausColors.foreground,
                              size: 58,
                              borderColor: BauhausColors.border,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onPass?.call();
                              },
                            ),
                            // Super Like (Star)
                            _buildActionButton(
                              icon: Icons.star,
                              color: BauhausColors.primaryYellow,
                              iconColor: BauhausColors.foreground,
                              size: 50,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onSuperLike?.call();
                              },
                            ),
                            // Like (Heart)
                            _buildActionButton(
                              icon: Icons.favorite,
                              color: BauhausColors.primaryRed,
                              iconColor: Colors.white,
                              size: 58,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onLike?.call();
                              },
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      if (widget.onChat != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: BauhausButton(
                            text: 'CHAT WITH ${profile.nickname.toUpperCase()}',
                            variant: BauhausButtonVariant.black,
                            isFullWidth: true,
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onChat?.call();
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Primary Action: UNMATCH
                            BauhausButton(
                              text: 'UNMATCH',
                              variant: BauhausButtonVariant.black,
                              isFullWidth: true,
                              icon: const Icon(
                                Icons.heart_broken_outlined,
                                size: 18,
                              ),
                              onPressed: () => _confirmUnmatch(context),
                            ),
                            const SizedBox(height: 10),
                            // Secondary Action: BLOCK
                            BauhausButton.outline(
                              text: 'BLOCK ${profile.nickname.toUpperCase()}',
                              isFullWidth: true,
                              icon: const Icon(
                                Icons.block,
                                size: 18,
                                color: BauhausColors.primaryRed,
                              ),
                              onPressed: () => _confirmBlock(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Safety Report Link
                    Center(
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: BauhausColors.foreground,
                        ),
                        label: Text(
                          'Report Student',
                          style: BauhausTextStyles.caption().copyWith(
                            color: BauhausColors.foreground,
                          ),
                        ),
                        onPressed: () {
                          ReportUserDialog.show(
                            context,
                            reportedStudent: profile,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Block & Unmatch Handlers ────────────────────────────────

  void _confirmUnmatch(BuildContext context) {
    final profile = widget.profile;
    BauhausDialog.show(
      context: context,
      title: 'Unmatch Student',
      headerColor: BauhausColors.primaryYellow,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BauhausColors.cardYellow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.heart_broken_outlined,
              size: 32,
              color: BauhausColors.foreground,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Unmatch with ${profile.name.toUpperCase()}?',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.title(),
          ),
          const SizedBox(height: 8),
          Text(
            'Unmatching will remove your conversation history. You may still encounter each other again in Discover in the future.',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.bodyMedium(),
          ),
        ],
      ),
      primaryActionText: 'UNMATCH',
      primaryActionVariant: BauhausButtonVariant.black,
      secondaryActionText: 'CANCEL',
      onPrimaryAction: () async {
        Navigator.of(context).pop(); // dismiss dialog
        Navigator.of(context).pop(); // dismiss bottom sheet

        final auth = context.read<AuthProvider>();
        final myUid = auth.firebaseUserId ?? auth.currentUser.id;
        final chat = context.read<ChatProvider>();
        final users = [myUid, profile.id]..sort();
        final convId = '${users[0]}_${users[1]}';

        await chat.unmatch(conversationId: convId, peerUid: profile.id);
        widget.onUnmatchedOrBlocked?.call();

        if (context.mounted) {
          BauhausSnackBar.showSuccess(
            context,
            'Unmatched with ${profile.nickname}',
          );
        }
      },
    );
  }

  void _confirmBlock(BuildContext context) {
    final profile = widget.profile;
    BauhausDialog.show(
      context: context,
      title: 'Block Student',
      headerColor: BauhausColors.primaryRed,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BauhausColors.primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.block,
              size: 32,
              color: BauhausColors.primaryRed,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Block ${profile.name.toUpperCase()}?',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.title(),
          ),
          const SizedBox(height: 8),
          Text(
            'Blocking will immediately unmatch and delete all chat history. This student will never appear in your Discover swipe feed or match with you again.',
            textAlign: TextAlign.center,
            style: BauhausTextStyles.bodyMedium(),
          ),
        ],
      ),
      primaryActionText: 'BLOCK USER',
      primaryActionVariant: BauhausButtonVariant.primaryRed,
      secondaryActionText: 'CANCEL',
      onPrimaryAction: () async {
        Navigator.of(context).pop(); // dismiss dialog
        Navigator.of(context).pop(); // dismiss bottom sheet

        final auth = context.read<AuthProvider>();
        final myUid = auth.firebaseUserId ?? auth.currentUser.id;
        final chat = context.read<ChatProvider>();
        final users = [myUid, profile.id]..sort();
        final convId = '${users[0]}_${users[1]}';

        await auth.blockUser(profile.id);
        await chat.block(conversationId: convId, peerUid: profile.id);
        widget.onUnmatchedOrBlocked?.call();

        if (context.mounted) {
          BauhausSnackBar.showError(
            context,
            'Blocked ${profile.nickname}. You will not see this student again.',
          );
        }
      },
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: iconColor, size: size * 0.48),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: BauhausColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: BauhausTextStyles.bodyMedium())),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: BauhausColors.border,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: BauhausTextStyles.badge(color: BauhausColors.foreground),
    );
  }

  Widget _buildIconText({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: BauhausColors.primaryRed),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: BauhausTextStyles.bodyMedium())),
      ],
    );
  }

  String _getEmojiForInterest(String interest) {
    final lower = interest.toLowerCase();
    if (lower.contains('basket')) {
      return '🏀';
    }
    if (lower.contains('badmin')) {
      return '🏸';
    }
    if (lower.contains('netflix') ||
        lower.contains('movie') ||
        lower.contains('film') ||
        lower.contains('cinema')) {
      return '🎬';
    }
    if (lower.contains('valo') ||
        lower.contains('game') ||
        lower.contains('gaming')) {
      return '🕹';
    }
    if (lower.contains('craft')) {
      return '🕹';
    }
    if (lower.contains('fifa') ||
        lower.contains('football') ||
        lower.contains('soccer') ||
        lower.contains('ball')) {
      return '⚽';
    }
    if (lower.contains('code') ||
        lower.contains('coding') ||
        lower.contains('dev') ||
        lower.contains('tech')) {
      return '💻';
    }
    if (lower.contains('coffee') || lower.contains('cafe')) {
      return '☕';
    }
    if (lower.contains('cat')) {
      return '🐱';
    }
    if (lower.contains('dog')) {
      return '🐶';
    }
    if (lower.contains('music') ||
        lower.contains('song') ||
        lower.contains('guitar') ||
        lower.contains('piano')) {
      return '🎵';
    }
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('workout')) {
      return '🏋️';
    }
    if (lower.contains('run') || lower.contains('jogging')) {
      return '🏃';
    }
    if (lower.contains('food') ||
        lower.contains('cook') ||
        lower.contains('ramen') ||
        lower.contains('eat')) {
      return '🍜';
    }
    if (lower.contains('book') ||
        lower.contains('read') ||
        lower.contains('study')) {
      return '📚';
    }
    return '✨';
  }
}
