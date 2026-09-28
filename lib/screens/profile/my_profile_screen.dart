import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_bottom_sheet.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'profile_preview_dialog.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: BauhausColors.surface,
                  border: Border(
                    bottom: BorderSide(color: BauhausColors.border, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    const GeometricBrandMark(size: 13, spacing: 5),
                    const SizedBox(width: 10),
                    Text(
                      'MY PROFILE',
                      style: BauhausTextStyles.headlineMedium().copyWith(
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Preview Profile',
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: BauhausColors.foreground,
                      ),
                      onPressed: () => ProfilePreviewDialog.show(context, user),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      icon: Icon(
                        Icons.settings,
                        color: BauhausColors.foreground,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      },
                    ),
                  ],
                ),
              ),

              // Hero Photo & Badge Banner
              Container(
                height: 240,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BauhausColors.border, width: 1.0),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      user.photos.isNotEmpty ? user.photos.first : '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: BauhausColors.primaryBlue,
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Verified Stamp
                    if (user.isVerifiedStudent)
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BauhausColors.cardYellow,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: BauhausColors.border,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: BauhausColors.primaryBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'VERIFIED STUDENT',
                                style: BauhausTextStyles.badge(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name & Faculty Block
                    BauhausCard(
                      cornerBadge: BauhausCornerBadgeType.circleRed,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.name}, ${user.age}'.toUpperCase(),
                                  style: BauhausTextStyles.headlineLarge()
                                      .copyWith(fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (user.faculty.isNotEmpty ||
                              user.major.isNotEmpty ||
                              user.year.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (user.faculty.isNotEmpty)
                                  BauhausBadge(
                                    label: user.faculty,
                                    variant: BauhausBadgeVariant.red,
                                  ),
                                if (user.major.isNotEmpty && user.major != '-')
                                  BauhausBadge(
                                    label: user.major,
                                    variant: BauhausBadgeVariant.blue,
                                  ),
                                if (user.year.isNotEmpty)
                                  BauhausBadge(
                                    label: user.year,
                                    variant: BauhausBadgeVariant.yellow,
                                  ),
                              ],
                            ),
                          ],
                          if (user.studentEmail.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              user.studentEmail,
                              style: BauhausTextStyles.caption(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats Module
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            title: 'MATCHES',
                            value: '${user.matchesCount}',
                            color: BauhausColors.primaryRed,
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatTile(
                            title: 'LIKES',
                            value: '${user.likesCount}',
                            color: BauhausColors.primaryYellow,
                            textColor: BauhausColors.foreground,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatTile(
                            title: 'PROFILE',
                            value:
                                '${(user.profileCompleteness * 100).round()}%',
                            color: BauhausColors.primaryBlue,
                            textColor: Colors.white,
                            onTap: () =>
                                _showCompletenessBreakdown(context, user),
                          ),
                        ),
                      ],
                    ),

                    if (user.profileCompleteness < 1.0) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showCompletenessBreakdown(context, user),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: BauhausColors.cardYellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BauhausColors.border,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates_outlined,
                                size: 18,
                                color: BauhausColors.foreground,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Profile is ${(user.profileCompleteness * 100).round()}% complete • Tap to see suggestions',
                                  style: BauhausTextStyles.caption(
                                    color: BauhausColors.foreground,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: BauhausColors.foreground,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Campus Bio
                      BauhausCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CAMPUS BIO',
                              style: BauhausTextStyles.title(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.bio,
                              style: BauhausTextStyles.bodyMedium(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (user.anthemSong.isNotEmpty ||
                        user.campusHangout.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Campus Anthem & Hangout
                      BauhausCard(
                        cornerBadge: BauhausCornerBadgeType.triangleYellow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CAMPUS VIBES',
                              style: BauhausTextStyles.title(),
                            ),
                            const SizedBox(height: 10),
                            if (user.anthemSong.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: BauhausColors.cardYellow,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: BauhausColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.music_note,
                                      color: BauhausColors.primaryRed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        user.anthemArtist.isNotEmpty
                                            ? '${user.anthemSong} — ${user.anthemArtist}'
                                            : user.anthemSong,
                                        style: BauhausTextStyles.bodyMedium()
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (user.campusHangout.isNotEmpty)
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
                                      user.campusHangout,
                                      style: BauhausTextStyles.bodyMedium(),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Campus Activities & Passions Chips
                    if (user.activities.isNotEmpty) ...[
                      BauhausCard(
                        cornerBadge: BauhausCornerBadgeType.triangleYellow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CAMPUS ACTIVITIES & PASSIONS',
                              style: BauhausTextStyles.title(),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: user.activities
                                  .map(
                                    (i) => BauhausBadge(
                                      label: i,
                                      variant: BauhausBadgeVariant.yellow,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tinder-style Interests & Lifestyle
                    if (user.profileInterests.isNotEmpty) ...[
                      BauhausCard(
                        cornerBadge: BauhausCornerBadgeType.circleRed,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INTERESTS & LIFESTYLE',
                              style: BauhausTextStyles.title(),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.profileInterests.displayItems.map((
                                item,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BauhausColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: BauhausColors.border,
                                      width: 1.0,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 14,
                                        color: BauhausColors.primaryRed,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${item.label}: ',
                                        style: BauhausTextStyles.badge()
                                            .copyWith(
                                              color: Colors.grey.shade700,
                                              fontSize: 10,
                                            ),
                                      ),
                                      Text(
                                        item.value,
                                        style: BauhausTextStyles.bodyMedium()
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 10),

                    // Safety Center Action
                    BauhausButton.outline(
                      text: 'CAMPUS SAFETY & REPORT CENTER',
                      isFullWidth: true,
                      height: 48,
                      icon: const Icon(Icons.shield, size: 18),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.safety);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletenessBreakdown(BuildContext context, StudentProfile user) {
    final checklist = user.completenessChecklist;
    final percent = (user.profileCompleteness * 100).round();

    BauhausBottomSheet.show(
      context: context,
      title: 'PROFILE COMPLETENESS ($percent%)',
      headerColor: percent == 100
          ? BauhausColors.primaryBlue
          : BauhausColors.primaryYellow,
      headerTextColor: percent == 100 ? Colors.white : BauhausColors.foreground,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: user.profileCompleteness,
                minHeight: 8,
                backgroundColor: BauhausColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  BauhausColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Complete your profile to 100% to boost matches and connect with campus peers.',
              style: BauhausTextStyles.caption(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            ...checklist.map((item) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    if (item.sectionKey == 'email') {
                      if (!user.isVerifiedStudent) {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.emailVerification);
                      } else {
                        BauhausSnackBar.showSuccess(
                          context,
                          'Your university email is already verified!',
                        );
                      }
                    } else {
                      Navigator.of(context).pushNamed(
                        AppRoutes.editProfile,
                        arguments: item.sectionKey,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: item.isCompleted
                                ? const Color(0xFF10B981)
                                : BauhausColors.muted,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: item.isCompleted
                                  ? const Color(0xFF10B981)
                                  : BauhausColors.border,
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            item.isCompleted
                                ? Icons.check
                                : Icons.circle_outlined,
                            size: 13,
                            color: item.isCompleted
                                ? Colors.white
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.title,
                            style: BauhausTextStyles.bodyMedium().copyWith(
                              fontSize: 13,
                              color: item.isCompleted
                                  ? BauhausColors.foreground
                                  : Colors.grey.shade700,
                              fontWeight: item.isCompleted
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '+${item.weightPercent}%',
                          style: BauhausTextStyles.badge().copyWith(
                            fontSize: 11,
                            color: item.isCompleted
                                ? const Color(0xFF10B981)
                                : BauhausColors.primaryRed,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 11,
                          color: item.isCompleted
                              ? Colors.grey.shade400
                              : BauhausColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 18),
            if (percent < 100)
              BauhausButton(
                text: 'EDIT PROFILE TO COMPLETE',
                variant: BauhausButtonVariant.black,
                isFullWidth: true,
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () {
                  Navigator.of(context).pop();
                  final firstIncomplete = user.completenessChecklist.firstWhere(
                    (item) => !item.isCompleted,
                    orElse: () => user.completenessChecklist.first,
                  );
                  if (firstIncomplete.sectionKey == 'email' &&
                      !user.isVerifiedStudent) {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.emailVerification);
                  } else {
                    Navigator.of(context).pushNamed(
                      AppRoutes.editProfile,
                      arguments: firstIncomplete.sectionKey,
                    );
                  }
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BauhausColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
