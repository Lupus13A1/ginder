import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_card.dart';
import '../../widgets/bauhaus_accordion.dart';
import '../../widgets/bauhaus_app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../models/student_profile.dart';
import 'report_dialog.dart';

class SafetyReportScreen extends StatelessWidget {
  const SafetyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: BauhausColors.background,
      appBar: const BauhausAppBar(
        title: 'SAFETY & REPORT',
        showBrandMark: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Verification Badge Banner
            BauhausCard(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              cornerBadge: BauhausCornerBadgeType.circleRed,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: BauhausColors.primaryYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BauhausColors.border,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      size: 28,
                      color: BauhausColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VERIFIED UNIVERSITY STUDENT',
                          style: BauhausTextStyles.title().copyWith(
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Authenticated via ${user.studentEmail}',
                          style: BauhausTextStyles.caption(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Campus Security Hotline Card
            BauhausCard.red(
              borderWidth: 3.0,
              shadowOffset: 5.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CAMPUS SECURITY & EMERGENCY',
                        style: BauhausTextStyles.title(
                          color: Colors.white,
                        ).copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you ever feel unsafe on campus or in surrounding areas, contact university security patrol 24/7.',
                    style: BauhausTextStyles.bodyMedium(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  BauhausButton.outline(
                    text: 'CALL CAMPUS DISPATCH: 02-218-0000',
                    isFullWidth: true,
                    height: 44,
                    icon: const Icon(
                      Icons.phone,
                      size: 16,
                      color: BauhausColors.foreground,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Simulating emergency call to Campus Security Control...',
                          ),
                          backgroundColor: BauhausColors.foreground,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Safety Guidelines Accordion
            Text('CAMPUS DATING GUIDELINES', style: BauhausTextStyles.title()),
            const SizedBox(height: 10),

            const BauhausAccordion(
              title: '1. ALWAYS MEET IN PUBLIC CAMPUS SPOTS',
              initiallyExpanded: true,
              content: Text(
                'For your first meetup, pick well-lit campus landmarks like the Faculty Library, central student union coffee shop, or sports stadium.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: BauhausColors.foreground,
                ),
              ),
            ),

            const BauhausAccordion(
              title: '2. PROTECT SENSITIVE STUDENT INFORMATION',
              content: Text(
                'Never share dormitory room numbers, financial details, or login passwords with anyone you meet on the platform.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: BauhausColors.foreground,
                ),
              ),
            ),

            const BauhausAccordion(
              title: '3. ZERO TOLERANCE FOR HARASSMENT',
              content: Text(
                'Ginder strictly prohibits any form of stalking, hate speech, sexual harassment, or non-consensual sharing of media. Offenders will have their university accounts terminated.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: BauhausColors.foreground,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Blocked Users Management
            Text('BLOCKED STUDENT ACCOUNTS', style: BauhausTextStyles.title()),
            const SizedBox(height: 10),
            if (auth.blockedUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BauhausColors.surface,
                  border: Border.all(color: BauhausColors.border, width: 2.0),
                ),
                child: Center(
                  child: Text(
                    'No blocked student accounts.',
                    style: BauhausTextStyles.bodyMedium(),
                  ),
                ),
              )
            else
              ...auth.blockedUsers.map((uid) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: BauhausColors.surface,
                    border: Border.all(color: BauhausColors.border, width: 2.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.block,
                        size: 18,
                        color: BauhausColors.primaryRed,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'STUDENT ID #$uid',
                          style: BauhausTextStyles.badge().copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => auth.unblockUser(uid),
                        child: Text(
                          'UNBLOCK',
                          style: BauhausTextStyles.button(
                            color: BauhausColors.primaryBlue,
                          ).copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Direct Report Trigger
            BauhausButton(
              text: 'REPORT AN INCIDENT / USER',
              variant: BauhausButtonVariant.primaryRed,
              isFullWidth: true,
              height: 50,
              icon: const Icon(Icons.report_problem, size: 18),
              onPressed: () {
                ReportUserDialog.show(
                  context,
                  reportedStudent: StudentProfile.sampleProfiles.first,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
