import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bauhaus_colors.dart';
import 'bauhaus_shapes.dart';

enum BauhausCornerBadgeType { circleRed, squareBlue, triangleYellow }

class BauhausCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderWidth;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final BauhausCornerBadgeType? cornerBadge;
  final Widget? headerTag;

  const BauhausCard({
    super.key,
    required this.child,
    this.backgroundColor = BauhausColors.surface,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
  });

  const BauhausCard.yellow({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
  }) : backgroundColor = BauhausColors.cardYellow;

  const BauhausCard.blue({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
  }) : backgroundColor = BauhausColors.cardBlue;

  const BauhausCard.red({
    super.key,
    required this.child,
    this.borderWidth = 3.0,
    this.shadowOffset = 5.0,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.cornerBadge,
    this.headerTag,
  }) : backgroundColor = BauhausColors.cardRed;

  @override
  State<BauhausCard> createState() => _BauhausCardState();
}

class _BauhausCardState extends State<BauhausCard> {
  bool _isPressed = false;

  Widget _buildCornerBadge() {
    if (widget.cornerBadge == null) return const SizedBox.shrink();
    switch (widget.cornerBadge!) {
      case BauhausCornerBadgeType.circleRed:
        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: BauhausColors.primaryRed,
              shape: BoxShape.circle,
              border: Border.all(color: BauhausColors.border, width: 2.0),
            ),
          ),
        );
      case BauhausCornerBadgeType.squareBlue:
        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: BauhausColors.primaryBlue,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: BauhausColors.border, width: 2.0),
            ),
          ),
        );
      case BauhausCornerBadgeType.triangleYellow:
        return const Positioned(
          top: 8,
          right: 8,
          child: BauhausTriangle(
            size: 14,
            color: BauhausColors.primaryYellow,
            borderWidth: 2.0,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;

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
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(
          _isPressed ? 2.0 : 0.0,
          _isPressed ? 2.0 : 0.0,
          0.0,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: BauhausColors.border,
            width: widget.borderWidth,
          ),
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                    color: BauhausColors.border,
                    offset: Offset(1, 1),
                    blurRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: BauhausColors.border,
                    offset: Offset(widget.shadowOffset, widget.shadowOffset),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
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
