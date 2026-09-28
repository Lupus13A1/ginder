import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class BauhausTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final bool isRequired;
  final Color? indicatorColor;

  const BauhausTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.isRequired = false,
    this.indicatorColor,
  });

  @override
  State<BauhausTextField> createState() => _BauhausTextFieldState();
}

class _BauhausTextFieldState extends State<BauhausTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = widget.fillColor ?? BauhausColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.indicatorColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.indicatorColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  margin: const EdgeInsets.only(right: 6),
                ),
              ],
              Text(
                widget.label!,
                style: BauhausTextStyles.badge(
                  color: BauhausColors.foreground,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: BauhausColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: BauhausTextStyles.bodyLarge(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: BauhausTextStyles.bodyMedium(
              color: BauhausColors.isDark
                  ? const Color(0xFF64748B)
                  : Colors.grey.shade500,
            ),
            errorText: widget.errorText,
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: BauhausColors.foreground,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BauhausColors.border, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BauhausColors.border, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(
                color: BauhausColors.primaryBlue,
                width: 2.0,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: BauhausColors.error, width: 1.0),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: BauhausColors.error, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
