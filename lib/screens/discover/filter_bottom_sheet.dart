import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/bauhaus_colors.dart';
import '../../theme/bauhaus_text_styles.dart';
import '../../widgets/bauhaus_button.dart';
import '../../widgets/bauhaus_badge.dart';
import '../../providers/discover_provider.dart';

class DiscoverFilterBottomSheet extends StatefulWidget {
  const DiscoverFilterBottomSheet({super.key});

  @override
  State<DiscoverFilterBottomSheet> createState() =>
      _DiscoverFilterBottomSheetState();
}

class _DiscoverFilterBottomSheetState extends State<DiscoverFilterBottomSheet> {
  late String _tempFaculty;
  late String _tempYear;

  final List<String> _faculties = [
    'All',
    'Architecture',
    'Engineering',
    'Communication Arts',
    'Medicine',
    'Business',
    'Science',
  ];

  final List<String> _years = [
    'All',
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
    'Postgrad',
  ];

  @override
  void initState() {
    super.initState();
    final discover = context.read<DiscoverProvider>();
    _tempFaculty = discover.selectedFaculty;
    _tempYear = discover.selectedYear;
  }

  void _applyFilters() {
    final discover = context.read<DiscoverProvider>();
    discover.setFacultyFilter(_tempFaculty);
    discover.setYearFilter(_tempYear);
    Navigator.of(context).pop();
  }

  void _reset() {
    context.read<DiscoverProvider>().resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Faculty Filter
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              color: BauhausColors.primaryRed,
              margin: const EdgeInsets.only(right: 6),
            ),
            Text(
              'FILTER BY FACULTY',
              style: BauhausTextStyles.badge().copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _faculties.map((f) {
            final isSelected = _tempFaculty == f;
            return BauhausBadge(
              label: f,
              isPill: false,
              variant: isSelected
                  ? BauhausBadgeVariant.red
                  : BauhausBadgeVariant.surface,
              onTap: () => setState(() => _tempFaculty = f),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 2. Study Year Filter
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              color: BauhausColors.primaryBlue,
              margin: const EdgeInsets.only(right: 6),
            ),
            Text(
              'FILTER BY STUDY YEAR',
              style: BauhausTextStyles.badge().copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _years.map((y) {
            final isSelected = _tempYear == y;
            return BauhausBadge(
              label: y,
              isPill: false,
              variant: isSelected
                  ? BauhausBadgeVariant.blue
                  : BauhausBadgeVariant.surface,
              onTap: () => setState(() => _tempYear = y),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            BauhausButton.outline(text: 'RESET', height: 48, onPressed: _reset),
            const SizedBox(width: 12),
            Expanded(
              child: BauhausButton(
                text: 'APPLY FILTERS',
                isFullWidth: true,
                height: 48,
                variant: BauhausButtonVariant.primaryRed,
                onPressed: _applyFilters,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
