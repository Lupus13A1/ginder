import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

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
                      'MY PROFILE',
                      style: BauhausTextStyles.headlineMedium().copyWith(
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
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
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: BauhausColors.border, width: 3.0),
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
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: BauhausColors.cardYellow,
                          border: Border.all(
                            color: BauhausColors.border,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: BauhausColors.border,
                              offset: Offset(3, 3),
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
                      borderWidth: 3.0,
                      shadowOffset: 5.0,
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
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              BauhausBadge(
                                label: user.faculty,
                                variant: BauhausBadgeVariant.red,
                              ),
                              BauhausBadge(
                                label: user.major,
                                variant: BauhausBadgeVariant.blue,
                              ),
                              BauhausBadge(
                                label: user.year,
                                variant: BauhausBadgeVariant.yellow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.studentEmail,
                            style: BauhausTextStyles.caption(
                              color: Colors.grey.shade600,
                            ),
                          ),
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Campus Bio
                    BauhausCard(
                      borderWidth: 3.0,
                      shadowOffset: 5.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CAMPUS BIO', style: BauhausTextStyles.title()),
                          const SizedBox(height: 6),
                          Text(user.bio, style: BauhausTextStyles.bodyMedium()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Campus Anthem & Hangout
                    BauhausCard(
                      borderWidth: 3.0,
                      shadowOffset: 5.0,
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
                                border: Border.all(
                                  color: BauhausColors.border,
                                  width: 1.5,
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
                                      '${user.anthemSong} — ${user.anthemArtist}',
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

                    const SizedBox(height: 16),

                    // Interests Chips
                    BauhausCard(
                      borderWidth: 3.0,
                      shadowOffset: 5.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INTERESTS & ACTIVITIES',
                            style: BauhausTextStyles.title(),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: user.interests
                                .map(
                                  (i) => BauhausBadge(
                                    label: i,
                                    variant: BauhausBadgeVariant.surface,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Edit Profile Action
                    BauhausButton(
                      text: 'EDIT CAMPUS PROFILE',
                      isFullWidth: true,
                      height: 50,
                      variant: BauhausButtonVariant.primaryBlue,
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.editProfile);
                      },
                    ),

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

  Widget _buildStatTile({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: BauhausColors.border, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: BauhausColors.border,
            offset: Offset(3, 3),
            blurRadius: 0,
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
    );
  }
}
