import 'package:flutter/material.dart';
import 'package:sadak/model/view/location_suggestion_model.dart';

class OverlaySuggestionList extends StatelessWidget {
  final List<LocationSuggestion> suggestions;
  final String query;
  final int highlightedIndex;
  final Function(LocationSuggestion) onSelected;

  const OverlaySuggestionList({
    super.key,
    required this.suggestions,
    required this.query,
    required this.highlightedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      elevation: 0,
      child: Container(
        height: 56.0 * 5,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final item = suggestions[index];

            return InkWell(
              onTap: () => onSelected(item),
              child: Container(
                height: 56,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.label,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
