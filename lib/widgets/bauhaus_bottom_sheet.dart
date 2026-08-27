import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class BauhausBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final Color headerColor;
  final Color headerTextColor;
  final Widget? trailing;

  const BauhausBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.headerColor = BauhausColors.primaryYellow,
    this.headerTextColor = BauhausColors.foreground,
    this.trailing,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    Color headerColor = BauhausColors.primaryYellow,
    Color headerTextColor = BauhausColors.foreground,
    Widget? trailing,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => BauhausBottomSheet(
        title: title,
        content: content,
        headerColor: headerColor,
        headerTextColor: headerTextColor,
        trailing: trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BauhausColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(color: BauhausColors.border, width: 3.5),
          left: BorderSide(color: BauhausColors.border, width: 3.5),
          right: BorderSide(color: BauhausColors.border, width: 3.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 48,
                height: 6,
                decoration: const BoxDecoration(
                  color: BauhausColors.border,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: headerColor,
                border: const Border(
                  top: BorderSide(color: BauhausColors.border, width: 2.0),
                  bottom: BorderSide(color: BauhausColors.border, width: 2.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: BauhausTextStyles.title(
                        color: headerTextColor,
                      ).copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  ?trailing,
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: BauhausColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: BauhausColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
