import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_text_field.dart';
import '../../widgets/bauhaus_dropdown.dart';
import '../../widgets/bauhaus_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _majorController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _selectedDob;
  String _selectedFaculty = 'Faculty of Engineering';
  String _selectedYear = 'Year 3 (Junior)';

  final List<String> _faculties = [
    'Faculty of Engineering',
    'Faculty of Architecture and Design',
    'Faculty of Information Technology and Digital Innovation (ITDI)',
    'Faculty of Applied Science',
    'Faculty of Technical Education',
    'College of Industrial Technology (CIT)',
    'Faculty of Business Administration',
    'Faculty of Business and Industrial Development (BID)',
    'Faculty of Business Administration and Service Industry (BAS)',
    'Faculty of Applied Arts',
    'Faculty of Agro-Industry',
    'Faculty of Industrial Technology and Management (FITM)',
    'Faculty of Engineering and Technology (Rayong)',
    'KMUTNB International College',
    'Thai-French Innovation Institute (TFII)',
    'Rayong / Prachinburi Campus Project',
  ];

  final List<String> _years = [
    'Year 1 (Freshman)',
    'Year 2 (Sophomore)',
    'Year 3 (Junior)',
    'Year 4 (Senior)',
    'Postgraduate',
  ];

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _majorController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final defaultDate = DateTime(now.year - 19, now.month, now.day);
    final initial = _selectedDob ?? defaultDate;
    final firstDate = DateTime(1950, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate)
          ? lastDate
          : (initial.isBefore(firstDate) ? firstDate : initial),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'SELECT DATE OF BIRTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BauhausColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: BauhausColors.foreground,
              surface: BauhausColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      BauhausSnackBar.showWarning(context, 'Please enter username');
      return;
    }

    if (_selectedDob == null) {
      BauhausSnackBar.showWarning(context, 'Please select date of birth');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      BauhausSnackBar.showWarning(context, 'Please enter university email');
      return;
    }

    if (_passwordController.text.isEmpty) {
      BauhausSnackBar.showWarning(context, 'Please enter password');
      return;
    }

    setState(() => _isEmailLoading = true);
    final age = _calculateAge(_selectedDob!);

    try {
      await context.read<AuthProvider>().register(
        name: username,
        nickname: username,
        age: age,
        faculty: _selectedFaculty,
        major: _majorController.text.trim().isNotEmpty
            ? _majorController.text.trim()
            : '-',
        year: _selectedYear,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        BauhausSnackBar.showSuccess(
          context,
          'Registration successful! Please verify your email to start.',
          duration: const Duration(seconds: 4),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.emailVerification);
      }
    } catch (e) {
      if (mounted) {
        BauhausSnackBar.showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isEmailLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isGoogleLoading = true);

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
        if (e.toString() == 'EMAIL_NOT_VERIFIED') {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppRoutes.emailVerification);
        } else {
          BauhausSnackBar.showError(context, e.toString());
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryBlue,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 1.0,
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
                cornerBadge: BauhausCornerBadgeType.squareBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BauhausTextField(
                            label: 'USERNAME',
                            hintText: 'e.g. art_somchai',
                            controller: _usernameController,
                            isRequired: true,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: BauhausColors.foreground,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BauhausTextField(
                            label: 'DATE OF BIRTH',
                            hintText: 'DD/MM/YYYY',
                            controller: _dobController,
                            readOnly: true,
                            isRequired: true,
                            onTap: _pickDateOfBirth,
                            prefixIcon: Icon(
                              Icons.calendar_month_outlined,
                              color: BauhausColors.foreground,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Faculty Selector
                    BauhausDropdown<String>(
                      label: 'FACULTY',
                      isRequired: true,
                      indicatorColor: BauhausColors.primaryRed,
                      value: _selectedFaculty,
                      items: _faculties,
                      itemLabel: (f) => f,
                      menuMaxHeight: 280,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedFaculty = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Major Field
                    BauhausTextField(
                      label: 'MAJOR',
                      hintText: 'e.g. Computer Engineering (CPE)',
                      controller: _majorController,
                      indicatorColor: BauhausColors.primaryBlue,
                      prefixIcon: Icon(
                        Icons.school_outlined,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Study Year Selector
                    BauhausDropdown<String>(
                      label: 'STUDY YEAR',
                      isRequired: true,
                      indicatorColor: BauhausColors.primaryYellow,
                      value: _selectedYear,
                      items: _years,
                      itemLabel: (y) => y,
                      menuMaxHeight: 240,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedYear = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),
                    BauhausTextField(
                      label: 'EMAIL',
                      hintText: 's6xx@email.kmutnb.ac.th',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      isRequired: true,
                      prefixIcon: Icon(
                        Icons.school_outlined,
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
                      isRequired: true,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: BauhausColors.foreground,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    BauhausButton(
                      text: 'CONTINUE TO PROFILE SETUP',
                      isFullWidth: true,
                      height: 52,
                      isLoading: _isEmailLoading,
                      variant: BauhausButtonVariant.primaryBlue,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: BauhausColors.border,
                            thickness: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR', style: BauhausTextStyles.badge()),
                        ),
                        Expanded(
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
                      isLoading: _isGoogleLoading,
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
