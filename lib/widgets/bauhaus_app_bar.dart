import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';
import 'bauhaus_shapes.dart';

class BauhausAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showBrandMark;
  final bool automaticallyImplyLeading;
  final double bottomBorderWidth;

  const BauhausAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = BauhausColors.surface,
    this.foregroundColor = BauhausColors.foreground,
    this.showBrandMark = true,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 3.0,
  });

  const BauhausAppBar.red({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 3.0,
  }) : backgroundColor = BauhausColors.primaryRed,
       foregroundColor = Colors.white;

  const BauhausAppBar.blue({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 3.0,
  }) : backgroundColor = BauhausColors.primaryBlue,
       foregroundColor = Colors.white;

  const BauhausAppBar.yellow({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 3.0,
  }) : backgroundColor = BauhausColors.primaryYellow,
       foregroundColor = BauhausColors.foreground;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null &&
        automaticallyImplyLeading &&
        Navigator.of(context).canPop()) {
      effectiveLeading = IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: backgroundColor == BauhausColors.surface
                ? BauhausColors.cardYellow
                : BauhausColors.surface,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: BauhausColors.border, width: 2.0),
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 18,
            color: BauhausColors.foreground,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: BauhausColors.border,
            width: bottomBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              if (effectiveLeading != null) ...[
                effectiveLeading,
                const SizedBox(width: 8),
              ],
              if (showBrandMark) ...[
                const GeometricBrandMark(size: 12, spacing: 5),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: BauhausTextStyles.title(
                    color: foregroundColor,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...?actions,
            ],
          ),
        ),
      ),
    );
  }
}
