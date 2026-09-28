import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';

enum BauhausSnackBarType { success, error, warning, info }

/// Premium floating notification snackbar system with distinct semantic hierarchy
class BauhausSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required BauhausSnackBarType type,
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Color accentColor;
    Color borderColor;
    Color iconBg;
    IconData iconData;
    String defaultTitle;

    switch (type) {
      case BauhausSnackBarType.success:
        accentColor = BauhausColors.success;
        borderColor = BauhausColors.successBorder;
        iconBg = BauhausColors.success.withValues(alpha: 0.12);
        iconData = Icons.check_circle_rounded;
        defaultTitle = 'SUCCESS';
        break;
      case BauhausSnackBarType.error:
        accentColor = BauhausColors.error;
        borderColor = BauhausColors.errorBorder;
        iconBg = BauhausColors.error.withValues(alpha: 0.12);
        iconData = Icons.error_rounded;
        defaultTitle = 'ERROR';
        break;
      case BauhausSnackBarType.warning:
        accentColor = BauhausColors.warning;
        borderColor = BauhausColors.warningBorder;
        iconBg = BauhausColors.warning.withValues(alpha: 0.12);
        iconData = Icons.warning_amber_rounded;
        defaultTitle = 'WARNING';
        break;
      case BauhausSnackBarType.info:
        accentColor = BauhausColors.info;
        borderColor = BauhausColors.infoBorder;
        iconBg = BauhausColors.info.withValues(alpha: 0.12);
        iconData = Icons.info_rounded;
        defaultTitle = 'INFO';
        break;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: BauhausColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor, width: 1.2),
        ),
        duration: duration,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(iconData, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title ?? defaultTitle,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: BauhausColors.foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Display a prominent, elegant success notification (Emerald Green)
  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      type: BauhausSnackBarType.success,
      title: title,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Display a clear, distinctive error alert (Crimson Red)
  static void showError(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      type: BauhausSnackBarType.error,
      title: title,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  /// Display a cautionary warning alert (Warm Amber)
  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      type: BauhausSnackBarType.warning,
      title: title,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Display an informative message (Azure / Indigo)
  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      type: BauhausSnackBarType.info,
      title: title,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
}
