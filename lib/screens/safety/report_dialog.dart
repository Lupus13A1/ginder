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
        title: 'Report Submitted',
        headerColor: BauhausColors.success,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BauhausColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 36,
                color: BauhausColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you for keeping campus safe',
              textAlign: TextAlign.center,
              style: BauhausTextStyles.title(),
            ),
            const SizedBox(height: 8),
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
      title: 'Report Student',
      headerColor: BauhausColors.error,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BauhausColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BauhausColors.border, width: 1.0),
              ),
              child: Row(
                children: [
                  BauhausAvatar(
                    imageUrl: widget.reportedStudent.photos.isNotEmpty
                        ? widget.reportedStudent.photos.first
                        : null,
                    initial: widget.reportedStudent.nickname[0],
                    size: 40,
                    isCircle: true,
                    backgroundColor: BauhausColors.primaryBlue,
                    borderWidth: 1.0,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reportedStudent.name,
                          style: BauhausTextStyles.title().copyWith(
                            fontSize: 14,
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

            const SizedBox(height: 16),
            Text('Select Reason:', style: BauhausTextStyles.badge()),
            const SizedBox(height: 8),
            ..._reasons.map((r) {
              final isSelected = _selectedReason == r;
              return GestureDetector(
                onTap: () => setState(() => _selectedReason = r),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BauhausColors.cardYellow
                        : BauhausColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? BauhausColors.primaryYellow
                          : BauhausColors.border,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: isSelected
                            ? BauhausColors.primaryYellow
                            : BauhausColors.foreground,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r,
                          style: BauhausTextStyles.bodyMedium().copyWith(
                            fontSize: 13,
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

            const SizedBox(height: 12),
            Text(
              'Additional Details (Optional):',
              style: BauhausTextStyles.badge(),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _detailsController,
              maxLines: 2,
              style: BauhausTextStyles.bodyMedium(
                color: BauhausColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'Describe the incident or behavior...',
                filled: true,
                fillColor: BauhausColors.background,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: BauhausColors.border,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: BauhausColors.border,
                    width: 1.0,
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
