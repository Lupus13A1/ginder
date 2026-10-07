import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';

enum BauhausAlertSeverity { success, warning, error, info }

/// Premium inline Alert banner widget for prominent contextual notifications
class BauhausAlertBanner extends StatelessWidget {
  final String message;
  final String? title;
  final BauhausAlertSeverity severity;
  final Widget? trailing;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const BauhausAlertBanner({
    super.key,
    required this.message,
    this.title,
    this.severity = BauhausAlertSeverity.warning,
    this.trailing,
    this.onClose,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color iconColor;
    Color textColor;
    IconData iconData;

    switch (severity) {
      case BauhausAlertSeverity.success:
        bg = BauhausColors.successLight;
        border = BauhausColors.successBorder;
        iconColor = BauhausColors.successText;
        textColor = BauhausColors.successText;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case BauhausAlertSeverity.error:
        bg = BauhausColors.errorLight;
        border = BauhausColors.errorBorder;
        iconColor = BauhausColors.errorText;
        textColor = BauhausColors.errorText;
        iconData = Icons.error_outline_rounded;
        break;
      case BauhausAlertSeverity.warning:
        bg = BauhausColors.warningLight;
        border = BauhausColors.warningBorder;
        iconColor = BauhausColors.warningText;
        textColor = BauhausColors.warningText;
        iconData = Icons.warning_amber_rounded;
        break;
      case BauhausAlertSeverity.info:
        bg = BauhausColors.infoLight;
        border = BauhausColors.infoBorder;
        iconColor = BauhausColors.infoText;
        textColor = BauhausColors.infoText;
        iconData = Icons.info_outline_rounded;
        break;
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          if (onClose != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                color: textColor.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
