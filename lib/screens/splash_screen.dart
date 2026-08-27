import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';
import '../widgets/bauhaus_shapes.dart';
import '../widgets/bauhaus_button.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _proceed() {
    final auth = context.read<AuthProvider>();
    if (!auth.isOnboarded) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BauhausColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top geometric header strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GeometricBrandMark(size: 16, spacing: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.cardYellow,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'EST. 2026 / CAMPUS EDITION',
                      style: BauhausTextStyles.badge(),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Animated Bauhaus Logo Hero Composition
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: BauhausColors.surface,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 4.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: BauhausColors.border,
                          offset: Offset(8, 8),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Red Circle
                        Positioned(
                          left: 15,
                          top: 15,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: BauhausColors.primaryRed,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BauhausColors.border,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                        // Blue Square
                        Positioned(
                          right: 15,
                          top: 40,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: BauhausColors.primaryBlue,
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: BauhausColors.border,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                        // Yellow Triangle
                        const Positioned(
                          left: 45,
                          bottom: 15,
                          child: BauhausTriangle(
                            size: 100,
                            color: BauhausColors.primaryYellow,
                            borderWidth: 3.0,
                          ),
                        ),
                        // Center GINDER Monogram Box
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: BauhausColors.foreground,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              'GINDER',
                              style: BauhausTextStyles.headlineLarge(
                                color: Colors.white,
                              ).copyWith(letterSpacing: 3.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Title and Manifest
              Text(
                'GINDER',
                textAlign: TextAlign.center,
                style: BauhausTextStyles.hero().copyWith(letterSpacing: -1.0),
              ),
              const SizedBox(height: 6),
              Container(
                alignment: Alignment.center,
                child: Text(
                  'FIND YOUR UNIVERSITY PARTNER',
                  textAlign: TextAlign.center,
                  style: BauhausTextStyles.badge(
                    color: BauhausColors.primaryRed,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Form follows attraction. Pure geometric campus connections, study buddies, and university dating.',
                textAlign: TextAlign.center,
                style: BauhausTextStyles.bodyMedium(
                  color: Colors.grey.shade700,
                ),
              ),

              const Spacer(),

              // Enter Button
              BauhausButton(
                text: 'ENTER CAMPUS',
                isFullWidth: true,
                height: 54,
                variant: BauhausButtonVariant.primaryRed,
                onPressed: _proceed,
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'BAUHAUS DESIGN SYSTEM V1.0 • CAMPUS VERIFIED',
                  style: BauhausTextStyles.caption(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
