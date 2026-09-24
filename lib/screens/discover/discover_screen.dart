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
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import 'filter_bottom_sheet.dart';
import '../../routes/app_routes.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  Animation<Offset>? _slideAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myUid = context.read<AuthProvider>().currentUser.id;
      context.read<DiscoverProvider>().loadProfiles(uid: myUid);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    if (dx > 100 || vx > 650) {
      _animateAndSwipe(
        targetOffset: Offset(screenWidth * 1.4, _dragOffset.dy + vy * 0.08),
        onComplete: _triggerLike,
      );
    } else if (dx < -100 || vx < -650) {
      _animateAndSwipe(
        targetOffset: Offset(-screenWidth * 1.4, _dragOffset.dy + vy * 0.08),
        onComplete: _triggerPass,
      );
    } else if (dy < -100 || vy < -650) {
      _animateAndSwipe(
        targetOffset: Offset(_dragOffset.dx, -screenHeight * 1.2),
        onComplete: _triggerSuperLike,
      );
    } else {
      _animateToCenter();
    }
  }

  void _animateAndSwipe({
    required Offset targetOffset,
    required VoidCallback onComplete,
    Duration duration = const Duration(milliseconds: 260),
  }) {
    if (_isAnimating) return;
    _isAnimating = true;

    final startOffset = _dragOffset;
    _animationController.duration = duration;

    _slideAnimation = Tween<Offset>(begin: startOffset, end: targetOffset)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    void updateListener() {
      if (mounted) {
        setState(() {
          _dragOffset = _slideAnimation!.value;
        });
      }
    }

    _animationController.addListener(updateListener);

    _animationController.forward(from: 0.0).then((_) {
      _animationController.removeListener(updateListener);
      if (!mounted) return;
      setState(() {
        _dragOffset = Offset.zero;
        _isAnimating = false;
      });
      onComplete();
    });
  }

  void _animateToCenter({
    Duration duration = const Duration(milliseconds: 240),
  }) {
    if (_isAnimating) return;
    _isAnimating = true;

    final startOffset = _dragOffset;
    _animationController.duration = duration;

    _slideAnimation = Tween<Offset>(begin: startOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    void updateListener() {
      if (mounted) {
        setState(() {
          _dragOffset = _slideAnimation!.value;
        });
      }
    }

    _animationController.addListener(updateListener);

    _animationController.forward(from: 0.0).then((_) {
      _animationController.removeListener(updateListener);
      if (!mounted) return;
      setState(() {
        _dragOffset = Offset.zero;
        _isAnimating = false;
      });
    });
  }

  void _swipeRightByButton() {
    if (_isAnimating || context.read<DiscoverProvider>().currentCard == null)
      return;
    final screenWidth = MediaQuery.of(context).size.width;
    _animateAndSwipe(
      targetOffset: Offset(screenWidth * 1.4, 25),
      onComplete: _triggerLike,
      duration: const Duration(milliseconds: 280),
    );
  }

  void _swipeLeftByButton() {
    if (_isAnimating || context.read<DiscoverProvider>().currentCard == null)
      return;
    final screenWidth = MediaQuery.of(context).size.width;
    _animateAndSwipe(
      targetOffset: Offset(-screenWidth * 1.4, 25),
      onComplete: _triggerPass,
      duration: const Duration(milliseconds: 280),
    );
  }

  void _swipeUpByButton() {
    if (_isAnimating || context.read<DiscoverProvider>().currentCard == null)
      return;
    final screenHeight = MediaQuery.of(context).size.height;
    _animateAndSwipe(
      targetOffset: Offset(0, -screenHeight * 1.2),
      onComplete: _triggerSuperLike,
      duration: const Duration(milliseconds: 280),
    );
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
        context.read<NotificationProvider>().addNotification(
          NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.newMatch,
            title: 'NEW MATCH!',
            message: 'You and ${matchedProfile.nickname} matched!',
            timestamp: DateTime.now(),
          ),
        );
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
        context.read<NotificationProvider>().addNotification(
          NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.newMatch,
            title: 'NEW MATCH!',
            message: 'You and ${matchedProfile.nickname} matched!',
            timestamp: DateTime.now(),
          ),
        );
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.matchFound, arguments: matchedProfile);
      }
    }
  }

  void _triggerRewind() async {
    if (_isAnimating) return;
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
                          // Background card under stack (smoothly scales up and rises like Tinder)
                          if (discover.profiles.length > 1)
                            Builder(
                              builder: (context) {
                                final dragDist = math.max(
                                  _dragOffset.dx.abs(),
                                  -_dragOffset.dy,
                                );
                                final swipeProgress = (dragDist / 160).clamp(
                                  0.0,
                                  1.0,
                                );
                                return Transform.translate(
                                  offset: Offset(0, 10 * (1 - swipeProgress)),
                                  child: Transform.scale(
                                    scale: 0.94 + (0.06 * swipeProgress),
                                    child: _buildCardWidget(
                                      discover.profiles[1],
                                      isBackground: true,
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Top interactive card
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTap: () {
                              if (!_isAnimating) {
                                _showProfileDetails(currentCard);
                              }
                            },
                            child: Transform.translate(
                              offset: _dragOffset,
                              child: Transform.rotate(
                                angle: (_dragOffset.dx / 320) * 0.35,
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
                    onTap: discover.canRewind && !_isAnimating
                        ? _triggerRewind
                        : null,
                  ),
                  // Pass (X)
                  _buildActionButton(
                    icon: Icons.close,
                    color: BauhausColors.surface,
                    iconColor: BauhausColors.foreground,
                    size: 58,
                    onTap: currentCard != null && !_isAnimating
                        ? _swipeLeftByButton
                        : null,
                  ),
                  // Super Like (Star)
                  _buildActionButton(
                    icon: Icons.star,
                    color: BauhausColors.primaryYellow,
                    iconColor: BauhausColors.foreground,
                    size: 50,
                    onTap: currentCard != null && !_isAnimating
                        ? _swipeUpByButton
                        : null,
                  ),
                  // Like (Heart)
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: BauhausColors.primaryRed,
                    iconColor: Colors.white,
                    size: 58,
                    onTap: currentCard != null && !_isAnimating
                        ? _swipeRightByButton
                        : null,
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
    return _TactileCircleButton(
      icon: icon,
      color: color,
      iconColor: iconColor,
      size: size,
      onTap: onTap,
    );
  }

  Widget _buildStampOverlay() {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;

    final likeOpacity = ((dx - 15) / 80).clamp(0.0, 1.0);
    final passOpacity = ((-dx - 15) / 80).clamp(0.0, 1.0);
    final superLikeOpacity = ((-dy - 15) / 80).clamp(0.0, 1.0);

    if (dx > 15 && dx.abs() >= -dy) {
      // LIKE STAMP
      return Positioned(
        top: 28,
        left: 24,
        child: Opacity(
          opacity: likeOpacity,
          child: Transform.rotate(
            angle: -math.pi / 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: BauhausColors.primaryRed,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BauhausColors.border, width: 3.0),
                boxShadow: const [
                  BoxShadow(color: BauhausColors.border, offset: Offset(3, 3)),
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
        ),
      );
    } else if (dx < -15 && dx.abs() >= -dy) {
      // PASS STAMP
      return Positioned(
        top: 28,
        right: 24,
        child: Opacity(
          opacity: passOpacity,
          child: Transform.rotate(
            angle: math.pi / 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: BauhausColors.foreground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: const [
                  BoxShadow(color: BauhausColors.border, offset: Offset(3, 3)),
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
        ),
      );
    } else if (dy < -15 && -dy > dx.abs()) {
      // SUPER LIKE STAMP
      return Positioned(
        top: 28,
        left: 0,
        right: 0,
        child: Center(
          child: Opacity(
            opacity: superLikeOpacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: BauhausColors.primaryYellow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BauhausColors.border, width: 3.0),
                boxShadow: const [
                  BoxShadow(color: BauhausColors.border, offset: Offset(3, 3)),
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
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardWidget(
    StudentProfile profile, {
    required bool isBackground,
  }) {
    const cardRadius = 24.0;
    const innerRadius = 20.5;

    return Container(
      decoration: BoxDecoration(
        color: BauhausColors.surface,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: BauhausColors.border, width: 3.5),
        boxShadow: isBackground
            ? const [
                BoxShadow(color: BauhausColors.border, offset: Offset(2, 2)),
              ]
            : const [
                BoxShadow(color: BauhausColors.border, offset: Offset(5, 5)),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
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
                    top: 14,
                    left: 14,
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
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BauhausColors.surface,
                          borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(16),
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
                      final isCommon = profile.commonInterests.contains(
                        interest,
                      );
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BauhausColors.border, width: 3.5),
          boxShadow: const [
            BoxShadow(color: BauhausColors.border, offset: Offset(5, 5)),
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: BauhausColors.border, width: 3.5),
          boxShadow: const [
            BoxShadow(color: BauhausColors.border, offset: Offset(5, 5)),
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

class _TactileCircleButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final VoidCallback? onTap;

  const _TactileCircleButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
    this.onTap,
  });

  @override
  State<_TactileCircleButton> createState() => _TactileCircleButtonState();
}

class _TactileCircleButtonState extends State<_TactileCircleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border.all(color: BauhausColors.border, width: 2.5),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: BauhausColors.border,
                      offset: _isPressed
                          ? const Offset(1, 1)
                          : const Offset(2.5, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.size * 0.48,
          ),
        ),
      ),
    );
  }
}
