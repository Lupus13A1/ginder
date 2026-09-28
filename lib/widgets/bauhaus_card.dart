import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bauhaus_colors.dart';

enum BauhausCornerBadgeType { circleRed, squareBlue, triangleYellow }

enum _BauhausCardColorType { defaultSurface, yellow, blue, red }

class BauhausCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BauhausCornerBadgeType? cornerBadge;
  final Widget? headerTag;
  final double borderRadius;
  final _BauhausCardColorType _colorType;

  const BauhausCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderWidth = 1.0,
    this.shadowOffset = 0.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
    this.borderRadius = 16.0,
  }) : _colorType = _BauhausCardColorType.defaultSurface;

  const BauhausCard.yellow({
    super.key,
    required this.child,
    this.borderWidth = 1.0,
    this.shadowOffset = 0.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
    this.borderRadius = 16.0,
  }) : backgroundColor = null,
       _colorType = _BauhausCardColorType.yellow;

  const BauhausCard.blue({
    super.key,
    required this.child,
    this.borderWidth = 1.0,
    this.shadowOffset = 0.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
    this.borderRadius = 16.0,
  }) : backgroundColor = null,
       _colorType = _BauhausCardColorType.blue;

  const BauhausCard.red({
    super.key,
    required this.child,
    this.borderWidth = 1.0,
    this.shadowOffset = 0.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
    this.borderRadius = 16.0,
  }) : backgroundColor = null,
       _colorType = _BauhausCardColorType.red;

  @override
  State<BauhausCard> createState() => _BauhausCardState();
}

class _BauhausCardState extends State<BauhausCard> {
  bool _isPressed = false;

  Color _resolveBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    switch (widget._colorType) {
      case _BauhausCardColorType.yellow:
        return BauhausColors.cardYellow;
      case _BauhausCardColorType.blue:
        return BauhausColors.cardBlue;
      case _BauhausCardColorType.red:
        return BauhausColors.cardRed;
      case _BauhausCardColorType.defaultSurface:
        return BauhausColors.surface;
    }
  }

  Widget _buildCornerBadge() {
    if (widget.cornerBadge == null) return const SizedBox.shrink();
    switch (widget.cornerBadge!) {
      case BauhausCornerBadgeType.circleRed:
        return Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: BauhausColors.primaryRed,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        );
      case BauhausCornerBadgeType.squareBlue:
        return Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: BauhausColors.primaryBlue,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        );
      case BauhausCornerBadgeType.triangleYellow:
        return Positioned(
          top: 10,
          right: 10,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: BauhausColors.primaryYellow,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;
    final effectiveBg = _resolveBackgroundColor();

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
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isInteractive
          ? () {
              setState(() => _isPressed = false);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          _isPressed ? 0.985 : 1.0,
          _isPressed ? 0.985 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: BauhausColors.border.withValues(alpha: 0.8),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: BauhausColors.isDark ? 0.25 : 0.04,
                    ),
                    offset: const Offset(0, 4),
                    blurRadius: 14,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(padding: widget.padding, child: widget.child),
              _buildCornerBadge(),
              if (widget.headerTag != null)
                Positioned(top: 0, left: 0, child: widget.headerTag!),
            ],
          ),
        ),
      ),
    );
  }
}
