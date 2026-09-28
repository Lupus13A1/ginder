import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';
import 'bauhaus_button.dart';

class BauhausDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final BauhausButtonVariant primaryActionVariant;
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
    this.primaryActionVariant = BauhausButtonVariant.primaryRed,
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
    BauhausButtonVariant primaryActionVariant = BauhausButtonVariant.primaryRed,
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
        primaryActionVariant: primaryActionVariant,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BauhausColors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: BauhausColors.isDark ? 0.35 : 0.1,
              ),
              offset: const Offset(0, 10),
              blurRadius: 30,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: headerColor == BauhausColors.primaryRed
                    ? BauhausColors.surface
                    : headerColor,
                border: Border(
                  bottom: BorderSide(color: BauhausColors.border, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 10)],
                  Expanded(
                    child: Text(
                      title,
                      style: BauhausTextStyles.title(
                        color: headerColor == BauhausColors.primaryRed
                            ? BauhausColors.foreground
                            : headerTextColor,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: BauhausColors.muted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
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
                        variant: primaryActionVariant,
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
