import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillSampleStudent(String email) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = 'student1234';
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: BauhausColors.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();
      if (mounted) {
        if (context.read<AuthProvider>().isProfileSetupComplete) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: BauhausColors.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              // Brand mark header
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
                      color: BauhausColors.cardYellow,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'CAMPUS AUTH',
                      style: BauhausTextStyles.badge(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Title Section
              Text('STUDENT\nLOGIN', style: BauhausTextStyles.hero()),
              const SizedBox(height: 8),
              Text(
                'Enter your university credentials or student ID to access campus partner discovery.',
                style: BauhausTextStyles.bodyMedium(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 24),

              // Login Form Card
              BauhausCard(
                borderWidth: 3.5,
                shadowOffset: 6.0,
                cornerBadge: BauhausCornerBadgeType.circleRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BauhausTextField(
                      label: 'UNIVERSITY EMAIL / STUDENT ID',
                      hintText: 'student.name@email.kmutnb.ac.th',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.school,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BauhausTextField(
                      label: 'PASSWORD',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'FORGOT PASSWORD?',
                          style: BauhausTextStyles.badge(
                            color: BauhausColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BauhausButton(
                      text: 'LOG IN TO CAMPUS',
                      isFullWidth: true,
                      height: 52,
                      isLoading: _isLoading,
                      variant: BauhausButtonVariant.primaryRed,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: BauhausColors.border,
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: BauhausTextStyles.badge()),
                        ),
                        const Expanded(
                          child: Divider(
                            color: BauhausColors.border,
                            thickness: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    BauhausButton.outline(
                      text: 'CONTINUE WITH GOOGLE',
                      isFullWidth: true,
                      height: 52,
                      icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                      onPressed: _handleGoogleAuth,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Sample Demo Accounts
              BauhausCard.yellow(
                borderWidth: 2.5,
                shadowOffset: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flash_on,
                          size: 16,
                          color: BauhausColors.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'QUICK DEMO STUDENT LOGINS:',
                          style: BauhausTextStyles.badge(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickLoginChip(
                          'Art (Arch)',
                          'art.thana@student.chula.ac.th',
                        ),
                        _buildQuickLoginChip(
                          'Mark (Eng)',
                          'tanawat.s@student.ku.ac.th',
                        ),
                        _buildQuickLoginChip(
                          'Mei (Comm Arts)',
                          'chanya.k@student.cmu.ac.th',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Register CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEW TO CAMPUS? ',
                    style: BauhausTextStyles.bodyMedium(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.register);
                    },
                    child: Text(
                      'CREATE ACCOUNT',
                      style: BauhausTextStyles.button(
                        color: BauhausColors.primaryRed,
                      ).copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginChip(String label, String email) {
    return GestureDetector(
      onTap: () => _fillSampleStudent(email),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 1.5),
        ),
        child: Text(
          label.toUpperCase(),
          style: BauhausTextStyles.badge(
            color: BauhausColors.foreground,
          ).copyWith(fontSize: 10),
        ),
      ),
    );
  }
}
