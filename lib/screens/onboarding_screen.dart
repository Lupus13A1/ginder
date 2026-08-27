import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../providers/auth_provider.dart';
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
      'title': 'DISCOVER YOUR CAMPUS',
      'subtitle': 'CROSS-FACULTY CONNECTIONS',
      'desc':
          'Find students across faculties, majors, and study years. Discover shared passions in art, coding, sports, and music.',
      'icon': Icons.explore,
      'tag': 'VERIFIED STUDENTS ONLY',
    },
    {
      'step': '02',
      'shape': BauhausCornerBadgeType.squareBlue,
      'color': BauhausColors.primaryBlue,
      'title': 'LIKE OR PASS WITH EASE',
      'subtitle': 'GEOMETRIC CARD STACK',
      'desc':
          'Swipe right to Like, left to Pass, or send a Super Like to make a bold impression on your university crush.',
      'icon': Icons.swap_horiz,
      'tag': 'TACTILE SWIPE ENGINE',
    },
    {
      'step': '03',
      'shape': BauhausCornerBadgeType.triangleYellow,
      'color': BauhausColors.primaryYellow,
      'title': 'MATCH & START CHATTING',
      'subtitle': 'SAFETY FIRST & DIRECT CHAT',
      'desc':
          'When mutual attraction occurs, break the ice instantly with custom campus conversation starters and hangout invites.',
      'icon': Icons.favorite,
      'tag': 'STUDENT VERIFIED CHAT',
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

  void _finishOnboarding() {
    context.read<AuthProvider>().completeOnboarding();
    Navigator.of(context).pushReplacementNamed(AppRoutes.register);
  }

  void _goToLogin() {
    context.read<AuthProvider>().completeOnboarding();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GeometricBrandMark(size: 14, spacing: 6),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'LOG IN',
                      style: BauhausTextStyles.button(
                        color: BauhausColors.foreground,
                      ),
                    ),
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
                      height: 8,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? colors[index] : BauhausColors.surface,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
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
                          borderWidth: 3.5,
                          shadowOffset: 6.0,
                          cornerBadge: slide['shape'] as BauhausCornerBadgeType,
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
                                      border: Border.all(
                                        color: BauhausColors.border,
                                        width: 2.0,
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
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BauhausColors.cardYellow,
                                      border: Border.all(
                                        color: BauhausColors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      slide['tag'] as String,
                                      style: BauhausTextStyles.badge(),
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
                                    color: (slide['color'] as Color).withAlpha(
                                      40,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: BauhausColors.border,
                                      width: 2.5,
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
                                (slide['subtitle'] as String).toUpperCase(),
                                style: BauhausTextStyles.badge(
                                  color: BauhausColors.primaryRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                slide['title'] as String,
                                style: BauhausTextStyles.headlineLarge(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                slide['desc'] as String,
                                style: BauhausTextStyles.bodyLarge(
                                  color: Colors.grey.shade800,
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
                      text: 'BACK',
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
                          ? 'GET STARTED'
                          : 'CONTINUE',
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
