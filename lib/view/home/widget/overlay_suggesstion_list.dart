import 'package:flutter/material.dart';
import 'package:sadak/model/map/location_suggesstion_model.dart';

class OverlaySuggestionList extends StatelessWidget {
  final List<LocationSuggestion> suggestions;
  final void Function(LocationSuggestion)
      onSelected;

  const OverlaySuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item =
              suggestions[index];

          return InkWell(
            onTap: () =>
                onSelected(item),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Text(
                item.label,
                style: theme
                    .textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
