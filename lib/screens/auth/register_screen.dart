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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _majorController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedFaculty = 'Architecture & Design';
  String _selectedYear = 'Year 3 (Junior)';

  final List<String> _faculties = [
    'Architecture & Design',
    'Engineering',
    'Communication Arts',
    'Medicine & Health',
    'Business Administration',
    'Science & Tech',
    'Faculty of Arts',
    'Faculty of Law',
  ];

  final List<String> _years = [
    'Year 1 (Freshman)',
    'Year 2 (Sophomore)',
    'Year 3 (Junior)',
    'Year 4 (Senior)',
    'Postgraduate',
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _majorController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    final age = int.tryParse(_ageController.text) ?? 20;

    try {
      await context.read<AuthProvider>().register(
        name: _nameController.text.isNotEmpty
            ? _nameController.text
            : 'New Student',
        nickname: _nicknameController.text.isNotEmpty
            ? _nicknameController.text
            : 'Student',
        age: age,
        faculty: _selectedFaculty,
        major: _majorController.text.isNotEmpty
            ? _majorController.text
            : 'General Studies',
        year: _selectedYear,
        email: _emailController.text.isNotEmpty
            ? _emailController.text
            : 'student@university.ac.th',
        password: _passwordController.text,
      );
      // We will never hit this because register() either throws VERIFICATION_REQUIRED or FirebaseAuthException
    } catch (e) {
      if (mounted) {
        if (e.toString() == 'VERIFICATION_REQUIRED') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful! Please check your email to verify your account.',
              ),
              backgroundColor: BauhausColors.primaryBlue,
              duration: Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: BauhausColors.primaryRed,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
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
              // Header
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
                      color: BauhausColors.primaryBlue,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      'STEP 1 OF 2',
                      style: BauhausTextStyles.badge(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text('STUDENT\nREGISTER', style: BauhausTextStyles.hero()),
              const SizedBox(height: 8),
              Text(
                'Join Ginder using your university credentials to connect with peers in your campus community.',
                style: BauhausTextStyles.bodyMedium(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              // Registration Card
              BauhausCard(
                borderWidth: 3.5,
                shadowOffset: 6.0,
                cornerBadge: BauhausCornerBadgeType.squareBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: BauhausTextField(
                            label: 'FULL NAME',
                            hintText: 'e.g. Somchai Prasert',
                            controller: _nameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: BauhausTextField(
                            label: 'NICKNAME',
                            hintText: 'e.g. Art',
                            controller: _nicknameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: BauhausTextField(
                            label: 'AGE',
                            hintText: 'e.g. 20',
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: BauhausTextField(
                            label: 'MAJOR / FIELD',
                            hintText: 'e.g. Computer Engineering',
                            controller: _majorController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Faculty Selector
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: BauhausColors.primaryRed,
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Text(
                          'FACULTY'.toUpperCase(),
                          style: BauhausTextStyles.badge().copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFaculty,
                          isExpanded: true,
                          style: BauhausTextStyles.bodyLarge(),
                          items: _faculties.map((f) {
                            return DropdownMenuItem(value: f, child: Text(f));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFaculty = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Study Year Selector
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          color: BauhausColors.primaryYellow,
                          margin: const EdgeInsets.only(right: 6),
                        ),
                        Text(
                          'STUDY YEAR'.toUpperCase(),
                          style: BauhausTextStyles.badge().copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: BauhausColors.surface,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 2.0,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedYear,
                          isExpanded: true,
                          style: BauhausTextStyles.bodyLarge(),
                          items: _years.map((y) {
                            return DropdownMenuItem(value: y, child: Text(y));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedYear = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    BauhausTextField(
                      label: 'UNIVERSITY EMAIL',
                      hintText: 'student.name@email.kmutnb.ac.th',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.school,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    BauhausTextField(
                      label: 'PASSWORD',
                      hintText: 'Create a password (min. 6 characters)',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    BauhausButton(
                      text: 'CONTINUE TO PROFILE SETUP',
                      isFullWidth: true,
                      height: 52,
                      isLoading: _isLoading,
                      variant: BauhausButtonVariant.primaryBlue,
                      onPressed: _handleRegister,
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
                      text: 'REGISTER WITH GOOGLE',
                      isFullWidth: true,
                      height: 52,
                      isLoading: _isLoading,
                      icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                      onPressed: _handleGoogleRegister,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ALREADY HAVE AN ACCOUNT? ',
                    style: BauhausTextStyles.bodyMedium(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Text(
                      'LOG IN',
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
