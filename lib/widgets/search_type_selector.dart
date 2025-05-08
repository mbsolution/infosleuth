import 'package:flutter/material.dart';

class SearchTypeSelector extends StatelessWidget {
  final List<String> types;
  final ValueChanged<String> onTypeChanged;
  const SearchTypeSelector({super.key, required this.types, required this.onTypeChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: types.map((t) {
        return ChoiceChip(
          label: Text(t),
          selected: false,
          onSelected: (_) => onTypeChanged(t),
        );
      }).toList(),
    );
  }
}
