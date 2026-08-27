import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';

/// Triangle CustomPainter following the Bauhaus Design System
class TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  const TrianglePainter({
    required this.color,
    this.borderColor = BauhausColors.border,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    if (borderWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) =>
      color != oldDelegate.color ||
      borderColor != oldDelegate.borderColor ||
      borderWidth != oldDelegate.borderWidth;
}

/// Bauhaus Triangle Widget
class BauhausTriangle extends StatelessWidget {
  final double size;
  final Color color;
  final Color borderColor;
  final double borderWidth;

  const BauhausTriangle({
    super.key,
    this.size = 24.0,
    this.color = BauhausColors.primaryYellow,
    this.borderColor = BauhausColors.border,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: TrianglePainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
      ),
    );
  }
}

/// The signature Bauhaus Geometric Brand Mark (🔴 Circle, 🟦 Square, 🔺 Triangle)
class GeometricBrandMark extends StatelessWidget {
  final double size;
  final double spacing;
  final Axis direction;

  const GeometricBrandMark({
    super.key,
    this.size = 14.0,
    this.spacing = 6.0,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      // Circle in Red
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: BauhausColors.primaryRed,
          shape: BoxShape.circle,
          border: Border.all(color: BauhausColors.border, width: 2.0),
        ),
      ),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      // Square in Blue
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: BauhausColors.primaryBlue,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: BauhausColors.border, width: 2.0),
        ),
      ),
      SizedBox(
        width: direction == Axis.horizontal ? spacing : 0,
        height: direction == Axis.vertical ? spacing : 0,
      ),
      // Triangle in Yellow
      BauhausTriangle(
        size: size,
        color: BauhausColors.primaryYellow,
        borderColor: BauhausColors.border,
        borderWidth: 2.0,
      ),
    ];

    return direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// A decorative Bauhaus composition for backgrounds and headers
class BauhausHeroPattern extends StatelessWidget {
  final double height;
  const BauhausHeroPattern({super.key, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Background solid strip
          Positioned.fill(child: Container(color: BauhausColors.cardYellow)),
          // Large Red Circle
          Positioned(
            left: -30,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: BauhausColors.primaryRed,
                shape: BoxShape.circle,
                border: Border.all(color: BauhausColors.border, width: 3.0),
              ),
            ),
          ),
          // Blue Rotated Square
          Positioned(
            right: 40,
            top: -10,
            child: Transform.rotate(
              angle: math.pi / 6,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: BauhausColors.primaryBlue,
                  border: Border.all(color: BauhausColors.border, width: 3.0),
                  boxShadow: const [
                    BoxShadow(
                      color: BauhausColors.border,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Yellow Triangle
          const Positioned(
            right: -10,
            bottom: -10,
            child: BauhausTriangle(
              size: 80,
              color: BauhausColors.primaryYellow,
              borderWidth: 3.0,
            ),
          ),
          // Stark black diagonal line / accent bar
          Positioned(
            left: 70,
            bottom: 15,
            child: Container(
              width: 80,
              height: 12,
              decoration: const BoxDecoration(color: BauhausColors.border),
            ),
          ),
        ],
      ),
    );
  }
}

/// Geometric avatar frame with Bauhaus borders and hard shadows
class BauhausAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initial;
  final double size;
  final Color backgroundColor;
  final bool isCircle;
  final double borderWidth;
  final double shadowOffset;
  final bool showVerifiedBadge;

  const BauhausAvatar({
    super.key,
    this.imageUrl,
    required this.initial,
    this.size = 54.0,
    this.backgroundColor = BauhausColors.primaryBlue,
    this.isCircle = true,
    this.borderWidth = 2.5,
    this.shadowOffset = 3.0,
    this.showVerifiedBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    if (imageUrl != null && imageUrl!.startsWith('http')) {
      avatarContent = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(),
      );
    } else {
      avatarContent = _buildFallbackInitial();
    }

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.zero,
        border: Border.all(color: BauhausColors.border, width: borderWidth),
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: BauhausColors.border,
                  offset: Offset(shadowOffset, shadowOffset),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarContent,
    );

    if (!showVerifiedBadge) return container;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        container,
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: BauhausColors.primaryYellow,
              shape: BoxShape.circle,
              border: Border.all(color: BauhausColors.border, width: 2.0),
            ),
            child: const Icon(
              Icons.verified,
              size: 14,
              color: BauhausColors.foreground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackInitial() {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: backgroundColor == BauhausColors.primaryYellow
              ? BauhausColors.foreground
              : Colors.white,
        ),
      ),
    );
  }
}
