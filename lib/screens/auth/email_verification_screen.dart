import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_snackbar.dart';
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
    // Auto-check every 3 seconds in case the user verifies in another tab/browser
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _checkVerificationStatus(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _autoCheckTimer = null;
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
        _autoCheckTimer?.cancel();
        BauhausSnackBar.showSuccess(context, 'Email verified successfully!');
        // Email is now verified — navigate forward directly
        if (auth.isProfileSetupComplete) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.profileSetup);
        }
      } else if (!silent && mounted) {
        BauhausSnackBar.showWarning(
          context,
          'Email not verified yet. Please check your inbox and click the verification link.',
        );
      }
    } catch (e) {
      if (!silent && mounted) {
        BauhausSnackBar.showError(context, e.toString());
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
        BauhausSnackBar.showSuccess(
          context,
          'Verification email resent! Please check your inbox or spam folder.',
        );
      }
    } catch (e) {
      if (mounted) {
        BauhausSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    _autoCheckTimer?.cancel();
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
        : (auth.firebaseUserEmail ?? 'your email');

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: BauhausColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand mark header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const GeometricBrandMark(size: 14, spacing: 6),
                    const BauhausBadge(
                      label: 'VERIFICATION REQUIRED',
                      variant: BauhausBadgeVariant.yellow,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Email icon composition
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: BauhausColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 52,
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
                  'We\'ve sent a verification link to your email. Please check your inbox and click the link to activate your account.',
                  textAlign: TextAlign.center,
                  style: BauhausTextStyles.bodyMedium(
                    color: BauhausColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Email display card
                BauhausCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: BauhausColors.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color: BauhausColors.primaryBlue,
                              size: 16,
                            ),
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
                        onPressed: () =>
                            _checkVerificationStatus(silent: false),
                      ),
                      const SizedBox(height: 12),

                      // Resend button
                      BauhausButton.outline(
                        text: 'RESEND VERIFICATION EMAIL',
                        isFullWidth: true,
                        height: 48,
                        isLoading: _isResending,
                        icon: Icon(
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
                          color: BauhausColors.textSecondary,
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
      ),
    );
  }
}
