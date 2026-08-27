import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

enum BauhausButtonVariant {
  primaryRed,
  primaryBlue,
  primaryYellow,
  outline,
  ghost,
  black,
}

enum BauhausButtonShape { square, pill }

class BauhausButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final BauhausButtonVariant variant;
  final BauhausButtonShape shape;
  final Widget? icon;
  final bool isFullWidth;
  final double height;
  final double shadowOffset;
  final double borderWidth;
  final double? fontSize;
  final bool isLoading;

  const BauhausButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BauhausButtonVariant.primaryRed,
    this.shape = BauhausButtonShape.square,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
    this.shadowOffset = 3.0,
    this.borderWidth = 2.5,
    this.fontSize,
    this.isLoading = false,
  });

  const BauhausButton.pill({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BauhausButtonVariant.primaryRed,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
    this.shadowOffset = 3.0,
    this.borderWidth = 2.5,
    this.fontSize,
    this.isLoading = false,
  }) : shape = BauhausButtonShape.pill;

  const BauhausButton.blue({
    super.key,
    required this.text,
    required this.onPressed,
    this.shape = BauhausButtonShape.square,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
    this.shadowOffset = 3.0,
    this.borderWidth = 2.5,
    this.fontSize,
    this.isLoading = false,
  }) : variant = BauhausButtonVariant.primaryBlue;

  const BauhausButton.yellow({
    super.key,
    required this.text,
    required this.onPressed,
    this.shape = BauhausButtonShape.square,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
    this.shadowOffset = 3.0,
    this.borderWidth = 2.5,
    this.fontSize,
    this.isLoading = false,
  }) : variant = BauhausButtonVariant.primaryYellow;

  const BauhausButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.shape = BauhausButtonShape.square,
    this.icon,
    this.isFullWidth = false,
    this.height = 50.0,
    this.shadowOffset = 3.0,
    this.borderWidth = 2.5,
    this.fontSize,
    this.isLoading = false,
  }) : variant = BauhausButtonVariant.outline;

  @override
  State<BauhausButton> createState() => _BauhausButtonState();
}

class _BauhausButtonState extends State<BauhausButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    if (widget.onPressed == null) return BauhausColors.muted;
    switch (widget.variant) {
      case BauhausButtonVariant.primaryRed:
        return BauhausColors.primaryRed;
      case BauhausButtonVariant.primaryBlue:
        return BauhausColors.primaryBlue;
      case BauhausButtonVariant.primaryYellow:
        return BauhausColors.primaryYellow;
      case BauhausButtonVariant.outline:
        return BauhausColors.surface;
      case BauhausButtonVariant.ghost:
        return Colors.transparent;
      case BauhausButtonVariant.black:
        return BauhausColors.foreground;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) return Colors.grey.shade600;
    switch (widget.variant) {
      case BauhausButtonVariant.primaryRed:
      case BauhausButtonVariant.primaryBlue:
      case BauhausButtonVariant.black:
        return Colors.white;
      case BauhausButtonVariant.primaryYellow:
      case BauhausButtonVariant.outline:
      case BauhausButtonVariant.ghost:
        return BauhausColors.foreground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPill = widget.shape == BauhausButtonShape.pill;
    final borderRadius = isPill
        ? BorderRadius.circular(999)
        : BorderRadius.zero;
    final isGhost = widget.variant == BauhausButtonVariant.ghost;
    final isInteractive = widget.onPressed != null && !widget.isLoading;

    final childContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.icon != null) ...[
          IconTheme(
            data: IconThemeData(color: _getTextColor(), size: 20),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text.toUpperCase(),
          style: BauhausTextStyles.button(
            color: _getTextColor(),
          ).copyWith(fontSize: widget.fontSize),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: isInteractive
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            }
          : null,
      onTapUp: isInteractive
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isInteractive
          ? () {
              setState(() => _isPressed = false);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        constraints: BoxConstraints(
          minHeight: widget.height,
          minWidth: widget.isFullWidth ? double.infinity : 48.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: borderRadius,
          border: isGhost
              ? null
              : Border.all(
                  color: BauhausColors.border,
                  width: widget.borderWidth,
                ),
          boxShadow: (isGhost || _isPressed || widget.onPressed == null)
              ? []
              : [
                  BoxShadow(
                    color: BauhausColors.border,
                    offset: Offset(widget.shadowOffset, widget.shadowOffset),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: childContent,
      ),
    );
  }
}
