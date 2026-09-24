import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Screen shown when a user is authenticated but has not yet verified their email.
/// Allows the user to:
///   - Check verification status (poll Firebase)
///   - Resend the verification email
///   - Log out and return to login
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isCheckingStatus = false;
  bool _isResending = false;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check every 5 seconds in case the user verifies in another tab
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerificationStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationStatus({bool silent = false}) async {
    if (_isCheckingStatus) return;

    if (!silent && mounted) {
      setState(() => _isCheckingStatus = true);
    }

    try {
      final auth = context.read<AuthProvider>();
      final isVerified = await auth.reloadUser();

      if (isVerified && mounted) {
        // Email is now verified — navigate forward
        if (auth.isProfileSetupComplete) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        }
      } else if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email not yet verified. Please check your inbox and click the verification link.',
            ),
            backgroundColor: BauhausColors.primaryYellow,
          ),
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: BauhausColors.primaryRed,
          ),
        );
      }
    } finally {
      if (!silent && mounted) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);

    try {
      await context.read<AuthProvider>().resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            backgroundColor: BauhausColors.primaryBlue,
          ),
        );
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
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userEmail = auth.currentUser.studentEmail.isNotEmpty
        ? auth.currentUser.studentEmail
        : 'your university email';

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
                      color: BauhausColors.primaryYellow,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'VERIFICATION REQUIRED',
                      style: BauhausTextStyles.badge(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Email icon composition
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: BauhausColors.surface,
                    border: Border.all(color: BauhausColors.border, width: 3.0),
                    boxShadow: const [
                      BoxShadow(
                        color: BauhausColors.border,
                        offset: Offset(5, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 56,
                    color: BauhausColors.primaryYellow,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                'VERIFY YOUR\nEMAIL',
                style: BauhausTextStyles.hero(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We\'ve sent a verification link to your university email. Please check your inbox and click the link to activate your account.',
                textAlign: TextAlign.center,
                style: BauhausTextStyles.bodyMedium(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 24),

              // Email display card
              BauhausCard(
                borderWidth: 3.0,
                shadowOffset: 5.0,
                cornerBadge: BauhausCornerBadgeType.triangleYellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: BauhausColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SENT TO',
                          style: BauhausTextStyles.badge(
                            color: BauhausColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: BauhausTextStyles.bodyLarge().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // "I've verified" button
                    BauhausButton(
                      text: "I'VE VERIFIED MY EMAIL",
                      isFullWidth: true,
                      height: 52,
                      isLoading: _isCheckingStatus,
                      variant: BauhausButtonVariant.primaryBlue,
                      onPressed: () => _checkVerificationStatus(silent: false),
                    ),
                    const SizedBox(height: 12),

                    // Resend button
                    BauhausButton.outline(
                      text: 'RESEND VERIFICATION EMAIL',
                      isFullWidth: true,
                      height: 48,
                      isLoading: _isResending,
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                        color: BauhausColors.foreground,
                      ),
                      onPressed: _resendVerification,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Help text
              BauhausCard(
                borderWidth: 2.0,
                shadowOffset: 3.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DIDN\'T RECEIVE THE EMAIL?',
                      style: BauhausTextStyles.badge(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam or junk folder\n'
                      '• Make sure you registered with @email.kmutnb.ac.th\n'
                      '• Wait a few minutes and try resending\n'
                      '• Contact support if the problem persists',
                      style: BauhausTextStyles.caption(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout link
              Center(
                child: GestureDetector(
                  onTap: _handleLogout,
                  child: Text(
                    'USE A DIFFERENT ACCOUNT',
                    style: BauhausTextStyles.button(
                      color: BauhausColors.primaryRed,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
