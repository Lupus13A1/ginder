import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import '../../models/student_profile.dart';
import '../../providers/discover_provider.dart';
import '../../providers/auth_provider.dart';
import 'filter_bottom_sheet.dart';
import '../../routes/app_routes.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUid = context.read<AuthProvider>().currentUser.id;
      context.read<DiscoverProvider>().loadProfiles(uid: myUid);
    });
  }

  void _onPanStart(DragStartDetails details) {}

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    if (dx > 120) {
      _triggerLike();
    } else if (dx < -120) {
      _triggerPass();
    } else if (dy < -120) {
      _triggerSuperLike();
    }

    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  void _triggerLike() async {
    HapticFeedback.mediumImpact();
    final myUid = context.read<AuthProvider>().currentUser.id;
    final isMatch = await context.read<DiscoverProvider>().likeCurrent(
      uid: myUid,
    );
    if (isMatch && mounted) {
      final matchedProfile = context
          .read<DiscoverProvider>()
          .currentMatchProfile;
      if (matchedProfile != null) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.matchFound, arguments: matchedProfile);
      }
    }
  }

  void _triggerPass() async {
    HapticFeedback.lightImpact();
    final myUid = context.read<AuthProvider>().currentUser.id;
    await context.read<DiscoverProvider>().passCurrent(uid: myUid);
  }

  void _triggerSuperLike() async {
    HapticFeedback.heavyImpact();
    final myUid = context.read<AuthProvider>().currentUser.id;
    final isMatch = await context.read<DiscoverProvider>().superLikeCurrent(
      uid: myUid,
    );
    if (isMatch && mounted) {
      final matchedProfile = context
          .read<DiscoverProvider>()
          .currentMatchProfile;
      if (matchedProfile != null) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.matchFound, arguments: matchedProfile);
      }
    }
  }

  void _triggerRewind() async {
    HapticFeedback.selectionClick();
    final myUid = context.read<AuthProvider>().currentUser.id;
    await context.read<DiscoverProvider>().rewind(uid: myUid);
  }

  void _openFilter() {
    BauhausBottomSheet.show(
      context: context,
      title: 'CAMPUS FILTERS',
      content: const DiscoverFilterBottomSheet(),
    );
  }

  void _showProfileDetails(StudentProfile profile) {
    BauhausBottomSheet.show(
      context: context,
      title: '${profile.name.toUpperCase()} (PROFILE)',
      headerColor: BauhausColors.primaryBlue,
      headerTextColor: Colors.white,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photos carousel / list
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: profile.photos.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                return Container(
                  width: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: BauhausColors.border, width: 2.5),
                  ),
                  child: Image.network(
                    profile.photos[idx],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.person, size: 50)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Faculty & Major
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              BauhausBadge(
                label: profile.faculty,
                variant: BauhausBadgeVariant.red,
              ),
              BauhausBadge(
                label: profile.major,
                variant: BauhausBadgeVariant.blue,
              ),
              BauhausBadge(
                label: profile.year,
                variant: BauhausBadgeVariant.yellow,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bio
          Text('ABOUT', style: BauhausTextStyles.title()),
          const SizedBox(height: 4),
          Text(profile.bio, style: BauhausTextStyles.bodyMedium()),
          const SizedBox(height: 16),

          // Anthem
          if (profile.anthemSong.isNotEmpty) ...[
            Text('CAMPUS ANTHEM', style: BauhausTextStyles.title()),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BauhausColors.cardYellow,
                border: Border.all(color: BauhausColors.border, width: 2.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: BauhausColors.primaryRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${profile.anthemSong} — ${profile.anthemArtist}',
                      style: BauhausTextStyles.bodyMedium().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Campus Hangout
          if (profile.campusHangout.isNotEmpty) ...[
            Text('FAVORITE CAMPUS HANGOUT', style: BauhausTextStyles.title()),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: BauhausColors.primaryBlue,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    profile.campusHangout,
                    style: BauhausTextStyles.bodyMedium(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Interests
          Text('INTERESTS & ACTIVITIES', style: BauhausTextStyles.title()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.interests.map((interest) {
              final isCommon = profile.commonInterests.contains(interest);
              return BauhausBadge(
                label: interest,
                variant: isCommon
                    ? BauhausBadgeVariant.yellow
                    : BauhausBadgeVariant.surface,
                icon: isCommon
                    ? const Icon(
                        Icons.star,
                        size: 12,
                        color: BauhausColors.primaryRed,
                      )
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discover = context.watch<DiscoverProvider>();
    final currentCard = discover.currentCard;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    'DISCOVER',
                    style: BauhausTextStyles.headlineMedium().copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  // Filter Button
                  GestureDetector(
                    onTap: _openFilter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            discover.selectedFaculty != 'All' ||
                                discover.selectedYear != 'All'
                            ? BauhausColors.primaryYellow
                            : BauhausColors.surface,
                        borderRadius: BorderRadius.zero,
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tune,
                            size: 16,
                            color: BauhausColors.foreground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            discover.selectedFaculty != 'All'
                                ? discover.selectedFaculty.toUpperCase()
                                : 'FILTERS',
                            style: BauhausTextStyles.badge(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reload Button
                  GestureDetector(
                    onTap: () {
                      final myUid = context.read<AuthProvider>().currentUser.id;
                      context.read<DiscoverProvider>().loadProfiles(
                        uid: myUid,
                        forceRefresh: true,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
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
                      child: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: BauhausColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Stack Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: discover.isLoading
                    ? _buildLoadingState()
                    : currentCard != null
                    ? Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Background card under stack (if exists)
                          if (discover.profiles.length > 1)
                            _buildCardWidget(
                              discover.profiles[1],
                              isBackground: true,
                            ),

                          // Top interactive card
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTap: () => _showProfileDetails(currentCard),
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: Transform.rotate(
                                angle: (_dragOffset.dx / 300) * (math.pi / 12),
                                child: Stack(
                                  children: [
                                    _buildCardWidget(
                                      currentCard,
                                      isBackground: false,
                                    ),
                                    _buildStampOverlay(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildEmptyState(),
              ),
            ),

            // Bottom Mechanical Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: BauhausColors.surface,
                border: Border(
                  top: BorderSide(color: BauhausColors.border, width: 3.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind
                  _buildActionButton(
                    icon: Icons.replay,
                    color: BauhausColors.surface,
                    iconColor: discover.canRewind
                        ? BauhausColors.foreground
                        : Colors.grey.shade400,
                    size: 46,
                    onTap: discover.canRewind ? _triggerRewind : null,
                  ),
                  // Pass (X)
                  _buildActionButton(
                    icon: Icons.close,
                    color: BauhausColors.surface,
                    iconColor: BauhausColors.foreground,
                    size: 58,
                    onTap: currentCard != null ? _triggerPass : null,
                  ),
                  // Super Like (Star)
                  _buildActionButton(
                    icon: Icons.star,
                    color: BauhausColors.primaryYellow,
                    iconColor: BauhausColors.foreground,
                    size: 50,
                    onTap: currentCard != null ? _triggerSuperLike : null,
                  ),
                  // Like (Heart)
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: BauhausColors.primaryRed,
                    iconColor: Colors.white,
                    size: 58,
                    onTap: currentCard != null ? _triggerLike : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 2.5),
          boxShadow: onTap != null
              ? const [
                  BoxShadow(
                    color: BauhausColors.border,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.48),
      ),
    );
  }

  Widget _buildStampOverlay() {
    if (_dragOffset.dx > 60) {
      // LIKE STAMP
      return Positioned(
        top: 30,
        left: 30,
        child: Transform.rotate(
          angle: -math.pi / 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: BauhausColors.primaryRed,
              border: Border.all(color: BauhausColors.border, width: 3.0),
              boxShadow: const [
                BoxShadow(color: BauhausColors.border, offset: Offset(4, 4)),
              ],
            ),
            child: Text(
              'LIKE',
              style: BauhausTextStyles.headlineLarge(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ),
        ),
      );
    } else if (_dragOffset.dx < -60) {
      // PASS STAMP
      return Positioned(
        top: 30,
        right: 30,
        child: Transform.rotate(
          angle: math.pi / 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: BauhausColors.foreground,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: const [
                BoxShadow(color: BauhausColors.border, offset: Offset(4, 4)),
              ],
            ),
            child: Text(
              'PASS',
              style: BauhausTextStyles.headlineLarge(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 2.0),
            ),
          ),
        ),
      );
    } else if (_dragOffset.dy < -60) {
      // SUPER LIKE STAMP
      return Positioned(
        top: 30,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: BauhausColors.primaryYellow,
              border: Border.all(color: BauhausColors.border, width: 3.0),
              boxShadow: const [
                BoxShadow(color: BauhausColors.border, offset: Offset(4, 4)),
              ],
            ),
            child: Text(
              '★ SUPER LIKE ★',
              style: BauhausTextStyles.headlineMedium(
                color: BauhausColors.foreground,
              ).copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardWidget(
    StudentProfile profile, {
    required bool isBackground,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BauhausColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: BauhausColors.border, width: 3.5),
        boxShadow: isBackground
            ? const [
                BoxShadow(color: BauhausColors.border, offset: Offset(2, 2)),
              ]
            : const [
                BoxShadow(color: BauhausColors.border, offset: Offset(6, 6)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo Frame
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  profile.photos.isNotEmpty ? profile.photos.first : '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: BauhausColors.cardYellow,
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        size: 80,
                        color: BauhausColors.foreground,
                      ),
                    ),
                  ),
                ),
                // Top Badges
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      BauhausBadge(
                        label: profile.faculty,
                        variant: BauhausBadgeVariant.red,
                        fontSize: 10,
                      ),
                      const SizedBox(width: 6),
                      BauhausBadge(
                        label: '${profile.distanceKm} KM',
                        variant: BauhausBadgeVariant.yellow,
                        fontSize: 10,
                        icon: const Icon(Icons.near_me, size: 10),
                      ),
                    ],
                  ),
                ),
                // Verified Badge
                if (profile.isVerifiedStudent)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: BauhausColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED',
                            style: BauhausTextStyles.badge().copyWith(
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Information Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: BauhausColors.surface,
              border: Border(
                top: BorderSide(color: BauhausColors.border, width: 3.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${profile.name}, ${profile.age}'.toUpperCase(),
                        style: BauhausTextStyles.headlineMedium().copyWith(
                          fontSize: 19,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    BauhausBadge(
                      label: profile.year,
                      variant: BauhausBadgeVariant.blue,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  profile.bio,
                  style: BauhausTextStyles.bodyMedium(
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Common Interests / Interests Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: profile.interests.take(3).map((interest) {
                    final isCommon = profile.commonInterests.contains(interest);
                    return BauhausBadge(
                      label: interest,
                      variant: isCommon
                          ? BauhausBadgeVariant.yellow
                          : BauhausBadgeVariant.surface,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final myUid = context.read<AuthProvider>().currentUser.id;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          border: Border.all(color: BauhausColors.border, width: 3.5),
          boxShadow: const [
            BoxShadow(color: BauhausColors.border, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GeometricBrandMark(size: 20, spacing: 8),
            const SizedBox(height: 20),
            Text('NO MORE CARDS', style: BauhausTextStyles.headlineLarge()),
            const SizedBox(height: 8),
            Text(
              'You have explored all active students matching your current filters.',
              textAlign: TextAlign.center,
              style: BauhausTextStyles.bodyMedium(),
            ),
            const SizedBox(height: 20),
            BauhausButton(
              text: 'RESET DECK & EXPAND',
              variant: BauhausButtonVariant.primaryRed,
              onPressed: () =>
                  context.read<DiscoverProvider>().resetDeck(uid: myUid),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          border: Border.all(color: BauhausColors.border, width: 3.5),
          boxShadow: const [
            BoxShadow(color: BauhausColors.border, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  BauhausColors.primaryRed,
                ),
                strokeWidth: 3.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SCANNING CAMPUS...',
              style: BauhausTextStyles.headlineMedium().copyWith(
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching real student profiles from database',
              style: BauhausTextStyles.bodyMedium(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
