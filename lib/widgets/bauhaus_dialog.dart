import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';
import 'bauhaus_button.dart';

class BauhausDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final Color headerColor;
  final Color headerTextColor;
  final Widget? icon;

  const BauhausDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.headerColor = BauhausColors.primaryRed,
    this.headerTextColor = Colors.white,
    this.icon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? primaryActionText,
    VoidCallback? onPrimaryAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    Color headerColor = BauhausColors.primaryRed,
    Color headerTextColor = Colors.white,
    Widget? icon,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (context) => BauhausDialog(
        title: title,
        content: content,
        primaryActionText: primaryActionText,
        onPrimaryAction: onPrimaryAction,
        secondaryActionText: secondaryActionText,
        onSecondaryAction: onSecondaryAction,
        headerColor: headerColor,
        headerTextColor: headerTextColor,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: BauhausColors.surface,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 3.5),
          boxShadow: const [
            BoxShadow(
              color: BauhausColors.border,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              color: headerColor,
              child: Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: BauhausTextStyles.title(
                        color: headerTextColor,
                      ).copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
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
            // Body Content
            Padding(padding: const EdgeInsets.all(18.0), child: content),
            // Actions
            if (primaryActionText != null || secondaryActionText != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (secondaryActionText != null) ...[
                      BauhausButton.outline(
                        text: secondaryActionText!,
                        height: 42,
                        fontSize: 12,
                        onPressed:
                            onSecondaryAction ??
                            () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (primaryActionText != null)
                      BauhausButton(
                        text: primaryActionText!,
                        height: 42,
                        fontSize: 12,
                        variant: BauhausButtonVariant.primaryRed,
                        onPressed:
                            onPrimaryAction ??
                            () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
