import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class BauhausAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBrandMark;
  final bool automaticallyImplyLeading;
  final double bottomBorderWidth;

  const BauhausAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.showBrandMark = true,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 1.0,
  });

  const BauhausAppBar.red({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 1.0,
  }) : backgroundColor = BauhausColors.primaryRed,
       foregroundColor = Colors.white;

  const BauhausAppBar.blue({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 1.0,
  }) : backgroundColor = BauhausColors.primaryBlue,
       foregroundColor = Colors.white;

  const BauhausAppBar.yellow({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBrandMark = false,
    this.automaticallyImplyLeading = true,
    this.bottomBorderWidth = 1.0,
  }) : backgroundColor = BauhausColors.primaryYellow,
       foregroundColor = Colors.black;

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? BauhausColors.surface;
    final effectiveFg = foregroundColor ?? BauhausColors.foreground;

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null &&
        automaticallyImplyLeading &&
        Navigator.of(context).canPop()) {
      effectiveLeading = IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BauhausColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: BauhausColors.border, width: 1.0),
          ),
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: BauhausColors.foreground,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
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
              Expanded(
                child: Text(
                  title,
                  style: BauhausTextStyles.title(
                    color: effectiveFg,
                  ).copyWith(fontWeight: FontWeight.w600),
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
