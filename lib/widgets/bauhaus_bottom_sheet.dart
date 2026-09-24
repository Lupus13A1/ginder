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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: BauhausColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: headerColor == BauhausColors.primaryYellow
                    ? BauhausColors.surface
                    : headerColor,
                border: const Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 1.0),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: BauhausTextStyles.title(
                        color: headerColor == BauhausColors.primaryYellow
                            ? BauhausColors.foreground
                            : headerTextColor,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (trailing != null) trailing!,
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: BauhausColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
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
