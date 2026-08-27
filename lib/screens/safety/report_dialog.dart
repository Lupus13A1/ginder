import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_dialog.dart';
import '../../widgets/bauhaus_shapes.dart';
import '../../widgets/bauhaus_button.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_provider.dart';

class ReportUserDialog extends StatefulWidget {
  final StudentProfile reportedStudent;

  const ReportUserDialog({super.key, required this.reportedStudent});

  static Future<void> show(
    BuildContext context, {
    required StudentProfile reportedStudent,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ReportUserDialog(reportedStudent: reportedStudent),
    );
  }

  @override
  State<ReportUserDialog> createState() => _ReportUserDialogState();
}

class _ReportUserDialogState extends State<ReportUserDialog> {
  String _selectedReason = 'Harassment or offensive language';
  final TextEditingController _detailsController = TextEditingController();
  bool _alsoBlock = true;
  bool _submitted = false;

  final List<String> _reasons = [
    'Harassment or offensive language',
    'Non-student or Impersonation',
    'Inappropriate profile photos / content',
    'Spam or commercial advertising',
    'Safety concerns or threats',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_alsoBlock) {
      context.read<AuthProvider>().blockUser(widget.reportedStudent.id);
    }
    setState(() => _submitted = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return BauhausDialog(
        title: 'REPORT SUBMITTED',
        headerColor: BauhausColors.primaryBlue,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BauhausColors.cardYellow,
                shape: BoxShape.circle,
                border: Border.all(color: BauhausColors.border, width: 2.0),
              ),
              child: const Icon(
                Icons.check,
                size: 36,
                color: BauhausColors.foreground,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'THANK YOU FOR KEEPING CAMPUS SAFE',
              textAlign: TextAlign.center,
              style: BauhausTextStyles.title(),
            ),
            const SizedBox(height: 6),
            Text(
              'Our student safety moderation team has received the report and taken action.',
              textAlign: TextAlign.center,
              style: BauhausTextStyles.bodyMedium(),
            ),
          ],
        ),
      );
    }

    return BauhausDialog(
      title: 'REPORT STUDENT',
      headerColor: BauhausColors.primaryRed,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student summary
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BauhausColors.background,
                border: Border.all(color: BauhausColors.border, width: 2.0),
              ),
              child: Row(
                children: [
                  BauhausAvatar(
                    imageUrl: widget.reportedStudent.photos.isNotEmpty
                        ? widget.reportedStudent.photos.first
                        : null,
                    initial: widget.reportedStudent.nickname[0],
                    size: 40,
                    isCircle: false,
                    backgroundColor: BauhausColors.primaryBlue,
                    borderWidth: 1.5,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reportedStudent.name.toUpperCase(),
                          style: BauhausTextStyles.title().copyWith(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.reportedStudent.faculty,
                          style: BauhausTextStyles.caption(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Text('SELECT REASON:', style: BauhausTextStyles.badge()),
            const SizedBox(height: 6),
            ..._reasons.map((r) {
              final isSelected = _selectedReason == r;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BauhausColors.cardYellow
                        : BauhausColors.surface,
                    border: Border.all(
                      color: BauhausColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 16,
                        color: isSelected
                            ? BauhausColors.primaryRed
                            : BauhausColors.foreground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r,
                          style: BauhausTextStyles.bodyMedium().copyWith(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),
            Text(
              'ADDITIONAL DETAILS (OPTIONAL):',
              style: BauhausTextStyles.badge(),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _detailsController,
              maxLines: 2,
              style: BauhausTextStyles.bodyMedium(
                color: BauhausColors.foreground,
              ),
              decoration: const InputDecoration(
                hintText: 'Describe the incident or behavior...',
                filled: true,
                fillColor: BauhausColors.background,
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                    color: BauhausColors.border,
                    width: 2.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _alsoBlock,
                  activeColor: BauhausColors.primaryRed,
                  onChanged: (v) => setState(() => _alsoBlock = v ?? true),
                ),
                Expanded(
                  child: Text(
                    'Also block this student immediately',
                    style: BauhausTextStyles.bodyMedium().copyWith(
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            BauhausButton(
              text: 'SUBMIT REPORT',
              variant: BauhausButtonVariant.primaryRed,
              isFullWidth: true,
              height: 46,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
