import 'package:flutter/material.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class BauhausDropdown<T> extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final Color? indicatorColor;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final Widget? prefixIcon;
  final double menuMaxHeight;

  const BauhausDropdown({
    super.key,
    this.label,
    this.isRequired = false,
    this.indicatorColor,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.menuMaxHeight = 260.0,
  });

  @override
  Widget build(BuildContext context) {
    // Defensively ensure value is valid within items to prevent Flutter DropdownButton assertion crashes
    final effectiveValue = (value != null && items.contains(value))
        ? value
        : (items.isNotEmpty ? items.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (indicatorColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  margin: const EdgeInsets.only(right: 6),
                ),
              ],
              Text(
                label!,
                style: BauhausTextStyles.badge(
                  color: BauhausColors.foreground,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              if (isRequired) ...[
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
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: BauhausColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BauhausColors.border, width: 1.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: effectiveValue,
              isExpanded: true,
              menuMaxHeight: menuMaxHeight,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              dropdownColor: BauhausColors.surface,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: BauhausColors.foreground,
                size: 22,
              ),
              hint: hintText != null
                  ? Text(
                      hintText!,
                      style: BauhausTextStyles.bodyMedium(
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((T item) {
                  return Row(
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          itemLabel(item),
                          style: BauhausTextStyles.bodyLarge().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: items.map((T item) {
                final isSelected = item == effectiveValue;
                return DropdownMenuItem<T>(
                  value: item,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? BauhausColors.cardBlue.withAlpha(50)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            itemLabel(item),
                            style: BauhausTextStyles.bodyMedium().copyWith(
                              fontSize: 13.5,
                              color: isSelected
                                  ? BauhausColors.primaryBlue
                                  : BauhausColors.foreground,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: BauhausColors.primaryBlue,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
