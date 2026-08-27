import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

enum BauhausBadgeVariant { red, blue, yellow, surface, black, muted }

class BauhausBadge extends StatelessWidget {
  final String label;
  final BauhausBadgeVariant variant;
  final bool isPill;
  final Widget? icon;
  final VoidCallback? onTap;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  const BauhausBadge({
    super.key,
    required this.label,
    this.variant = BauhausBadgeVariant.yellow,
    this.isPill = true,
    this.icon,
    this.onTap,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    this.borderWidth = 1.5,
  });

  const BauhausBadge.square({
    super.key,
    required this.label,
    this.variant = BauhausBadgeVariant.yellow,
    this.icon,
    this.onTap,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.borderWidth = 1.5,
  }) : isPill = false;

  Color _getBackgroundColor() {
    switch (variant) {
      case BauhausBadgeVariant.red:
        return BauhausColors.primaryRed;
      case BauhausBadgeVariant.blue:
        return BauhausColors.primaryBlue;
      case BauhausBadgeVariant.yellow:
        return BauhausColors.primaryYellow;
      case BauhausBadgeVariant.surface:
        return BauhausColors.surface;
      case BauhausBadgeVariant.black:
        return BauhausColors.foreground;
      case BauhausBadgeVariant.muted:
        return BauhausColors.muted;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case BauhausBadgeVariant.red:
      case BauhausBadgeVariant.blue:
      case BauhausBadgeVariant.black:
        return Colors.white;
      case BauhausBadgeVariant.yellow:
      case BauhausBadgeVariant.surface:
      case BauhausBadgeVariant.muted:
        return BauhausColors.foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();

    Widget badgeWidget = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isPill ? BorderRadius.circular(999) : BorderRadius.zero,
        border: Border.all(color: BauhausColors.border, width: borderWidth),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: fontSize + 2),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: BauhausTextStyles.badge(
              color: textColor,
            ).copyWith(fontSize: fontSize),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: badgeWidget);
    }

    return badgeWidget;
  }
}
