import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ChildSelectorChips extends StatelessWidget {
  const ChildSelectorChips({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final List<Map<String, dynamic>> children;
  final int? selectedChildId;
  final ValueChanged<int> onSelected;
  final EdgeInsets padding;

  String _childName(Map<String, dynamic> child) {
    final displayName = child['display_name'] as String?;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    final username = child['username'] as String?;
    if (username != null && username.trim().isNotEmpty) {
      return username.trim();
    }
    return 'Child';
  }

  @override
  Widget build(BuildContext context) {
    if (children.length <= 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children.map((child) {
            final id = child['id'] as int;
            final selected = id == selectedChildId;
            return ChoiceChip(
              label: Text(
                _childName(child),
                overflow: TextOverflow.ellipsis,
              ),
              selected: selected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
              onSelected: (_) => onSelected(id),
            );
          }).toList(),
        ),
      ),
    );
  }
}
