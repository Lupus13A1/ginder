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
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isEmailLoading = true);

    try {
      await context.read<AuthProvider>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            backgroundColor: BauhausColors.primaryBlue,
          ),
        );
        final auth = context.read<AuthProvider>();
        if (!auth.isProfileSetupComplete) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
        setState(() => _isEmailLoading = false);
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isGoogleLoading = true);

    try {
      await context.read<AuthProvider>().signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful'),
            backgroundColor: BauhausColors.primaryBlue,
          ),
        );
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
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                cornerBadge: BauhausCornerBadgeType.squareBlue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('RESET PASSWORD', style: BauhausTextStyles.title()),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your university email to receive a password reset link.',
                      style: BauhausTextStyles.bodyMedium(),
                    ),
                    const SizedBox(height: 16),
                    BauhausTextField(
                      label: 'UNIVERSITY EMAIL',
                      hintText: 'student.name@email.kmutnb.ac.th',
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: BauhausButton.outline(
                            text: 'CANCEL',
                            height: 44,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BauhausButton(
                            text: 'SEND LINK',
                            height: 44,
                            isLoading: isResetting,
                            variant: BauhausButtonVariant.primaryBlue,
                            onPressed: () async {
                              setStateDialog(() => isResetting = true);
                              try {
                                await context
                                    .read<AuthProvider>()
                                    .resetPassword(resetEmailController.text);
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Password reset link sent! Check your inbox.',
                                      ),
                                      backgroundColor:
                                          BauhausColors.primaryBlue,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: BauhausColors.primaryRed,
                                    ),
                                  );
                                }
                              } finally {
                                if (ctx.mounted) {
                                  setStateDialog(() => isResetting = false);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                        onPressed: _showForgotPasswordDialog,
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
                      isLoading: _isEmailLoading,
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
                      isLoading: _isGoogleLoading,
                      icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                      onPressed: _handleGoogleAuth,
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
}
