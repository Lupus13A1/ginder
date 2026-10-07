import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_config_provider.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'step': '01',
      'shape': BauhausCornerBadgeType.circleRed,
      'color': BauhausColors.primaryRed,
      'title_en': 'DISCOVER YOUR CAMPUS',
      'title_th': 'ค้นพบเพื่อนในมหาวิทยาลัย',
      'subtitle_en': 'CROSS-FACULTY CONNECTIONS',
      'subtitle_th': 'เชื่อมต่อหลากหลายคณะ',
      'desc_en':
          'Find students across faculties, majors, and study years. Discover shared passions in art, coding, sports, and music.',
      'desc_th':
          'ค้นหาเพื่อนนักศึกษาต่างคณะ ต่างสาขา และต่างชั้นปี แชร์ความสนใจด้านศิลปะ โค้ดดิ้ง กีฬา และดนตรีร่วมกัน',
      'icon': Icons.explore,
      'tag_en': 'VERIFIED STUDENTS ONLY',
      'tag_th': 'เฉพาะนักศึกษาตัวจริง',
    },
    {
      'step': '02',
      'shape': BauhausCornerBadgeType.squareBlue,
      'color': BauhausColors.primaryBlue,
      'title_en': 'LIKE OR PASS WITH EASE',
      'title_th': 'ถูกใจหรือข้ามได้ง่ายดาย',
      'subtitle_en': 'GEOMETRIC CARD STACK',
      'subtitle_th': 'การ์ดเรขาคณิตบาวเฮาส์',
      'desc_en':
          'Swipe right to Like, left to Pass, or send a Super Like to make a bold impression on your university crush.',
      'desc_th':
          'ปัดขวาเพื่อกดถูกใจ ปัดซ้ายเพื่อข้าม หรือส่ง Super Like เพื่อสร้างความประทับใจให้กับคนที่คุณสนใจ',
      'icon': Icons.swap_horiz,
      'tag_en': 'TACTILE SWIPE ENGINE',
      'tag_th': 'ระบบปัดการ์ดลื่นไหล',
    },
    {
      'step': '03',
      'shape': BauhausCornerBadgeType.triangleYellow,
      'color': BauhausColors.primaryYellow,
      'title_en': 'MATCH & START CHATTING',
      'title_th': 'แมตช์แล้วเริ่มพูดคุยทันที',
      'subtitle_en': 'SAFETY FIRST & DIRECT CHAT',
      'subtitle_th': 'ปลอดภัยและส่งข้อความตรง',
      'desc_en':
          'When mutual attraction occurs, break the ice instantly with custom campus conversation starters and hangout invites.',
      'desc_th':
          'เมื่อถูกใจตรงกัน เริ่มต้นบทสนทนาได้ทันทีด้วยหัวข้อทักทายและคำชวนไปทำกิจกรรมร่วมกันในมหาลัย',
      'icon': Icons.favorite,
      'tag_en': 'STUDENT VERIFIED CHAT',
      'tag_th': 'แชทนักศึกษาปลอดภัย',
    },
  ];

  void _nextPage() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await context.read<AuthProvider>().completeOnboarding();
    if (mounted) {
      await context.read<AppConfigProvider>().completeOnboarding();
      Navigator.of(context).pushReplacementNamed(AppRoutes.register);
    }
  }

  Future<void> _skipOnboarding() async {
    await context.read<AuthProvider>().completeOnboarding();
    if (mounted) {
      await context.read<AppConfigProvider>().completeOnboarding();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  Future<void> _goToLogin() async {
    await context.read<AuthProvider>().completeOnboarding();
    if (mounted) {
      await context.read<AppConfigProvider>().completeOnboarding();
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = context.watch<AppConfigProvider>();

    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Brand Mark, Skip and Log In buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GeometricBrandMark(size: 14, spacing: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          appConfig.tr('SKIP', 'ข้าม'),
                          style: BauhausTextStyles.button(
                            color: BauhausColors.foreground.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          appConfig.tr('LOG IN', 'เข้าสู่ระบบ'),
                          style: BauhausTextStyles.button(
                            color: BauhausColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Step indicator
              Row(
                children: List.generate(3, (index) {
                  final isActive = index == _currentIndex;
                  final colors = [
                    BauhausColors.primaryRed,
                    BauhausColors.primaryBlue,
                    BauhausColors.primaryYellow,
                  ];
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? colors[index] : BauhausColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.0,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Slide content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Card composition
                        BauhausCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: slide['color'] as Color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: BauhausColors.border,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      slide['step'] as String,
                                      style: BauhausTextStyles.headlineMedium(
                                        color:
                                            slide['color'] ==
                                                BauhausColors.primaryYellow
                                            ? BauhausColors.foreground
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BauhausColors.cardYellow,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: BauhausColors.border,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      appConfig.tr(
                                        slide['tag_en'] as String,
                                        slide['tag_th'] as String,
                                      ),
                                      style: BauhausTextStyles.badge().copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: (slide['color'] as Color).withValues(
                                      alpha: 0.15,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: BauhausColors.border,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Icon(
                                    slide['icon'] as IconData,
                                    size: 44,
                                    color: BauhausColors.foreground,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                appConfig
                                    .tr(
                                      slide['subtitle_en'] as String,
                                      slide['subtitle_th'] as String,
                                    )
                                    .toUpperCase(),
                                style: BauhausTextStyles.badge(
                                  color: BauhausColors.primaryRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appConfig.tr(
                                  slide['title_en'] as String,
                                  slide['title_th'] as String,
                                ),
                                style: BauhausTextStyles.headlineLarge(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                appConfig.tr(
                                  slide['desc_en'] as String,
                                  slide['desc_th'] as String,
                                ),
                                style: BauhausTextStyles.bodyLarge(
                                  color: BauhausColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Actions
              Row(
                children: [
                  if (_currentIndex > 0) ...[
                    BauhausButton.outline(
                      text: appConfig.tr('BACK', 'ย้อนกลับ'),
                      height: 52,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: BauhausButton(
                      text: _currentIndex == _slides.length - 1
                          ? appConfig.tr('GET STARTED', 'เริ่มต้นใช้งาน')
                          : appConfig.tr('CONTINUE', 'ถัดไป'),
                      isFullWidth: true,
                      height: 52,
                      variant: _currentIndex == 1
                          ? BauhausButtonVariant.primaryBlue
                          : (_currentIndex == 2
                                ? BauhausButtonVariant.primaryYellow
                                : BauhausButtonVariant.primaryRed),
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
