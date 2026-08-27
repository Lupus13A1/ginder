import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class BauhausAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final Widget? leading;
  final double borderWidth;
  final double shadowOffset;

  const BauhausAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.leading,
    this.borderWidth = 3.0,
    this.shadowOffset = 4.0,
  });

  @override
  State<BauhausAccordion> createState() => _BauhausAccordionState();
}

class _BauhausAccordionState extends State<BauhausAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final headerBg = _isExpanded
        ? BauhausColors.primaryRed
        : BauhausColors.surface;
    final headerTextColor = _isExpanded
        ? Colors.white
        : BauhausColors.foreground;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: BauhausColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: BauhausColors.border,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: BauhausColors.border,
            offset: Offset(widget.shadowOffset, widget.shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              color: headerBg,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      widget.title.toUpperCase(),
                      style: BauhausTextStyles.title(
                        color: headerTextColor,
                      ).copyWith(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: headerTextColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: BauhausColors.cardYellow,
                border: Border(
                  top: BorderSide(color: BauhausColors.border, width: 3.0),
                ),
              ),
              child: widget.content,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
