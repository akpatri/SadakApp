import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/geo_json_property_model.dart';
import 'package:sadak/model/map/location_suggesstion_model.dart';
import 'package:sadak/view/home/widget/overlay_suggesstion_list.dart';

enum LocationFieldType { source, destination }

class LocationAutocompleteField extends ConsumerStatefulWidget {
  final LocationFieldType type;
  final void Function(String, double?, double?)? onSelected;

  const LocationAutocompleteField({
    super.key,
    required this.type,
    this.onSelected,
  });

  @override
  ConsumerState<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState
    extends ConsumerState<LocationAutocompleteField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    if (widget.type == LocationFieldType.source) {
      Future.microtask(_loadCurrentLocation);
    }
  }

  Future<void> _loadCurrentLocation() async {
    await ref
        .read(geoJsonCollectionProvider.notifier)
        .setCurrentLocationAsSource();
  }

  @override
  Widget build(BuildContext context) {
    /// Listen for geoJson updates
    ref.listen<AsyncValue<GeoJsonFeatureCollection>>(
      geoJsonCollectionProvider,
      (previous, next) {
        next.whenData((collection) {
          for (final feature in collection.features) {
            final property = GeoJsonProperty.fromDynamic(feature.properties);

            if (property == null) continue;

            if (property.type == widget.type.name) {
              final label = property.label;

              if (label != null && _controller.text != label) {
                _controller.text = label;
              }
            }
          }
        });
      },
    );

    final asyncSuggestions = ref.watch(locationAutocompleteProvider);

    final notifier = ref.read(locationAutocompleteProvider.notifier);

    final isActiveField = notifier.activeSearchFieldType == widget.type;

    return RawAutocomplete<LocationSuggestion>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.label,

      optionsBuilder: (value) {
        if (value.text.isEmpty) {
          return const Iterable<LocationSuggestion>.empty();
        }

        return asyncSuggestions.maybeWhen(
          data: (data) => data,
          orElse: () => const Iterable<LocationSuggestion>.empty(),
        );
      },

      onSelected: (selection) {
        final notifier = ref.read(locationAutocompleteProvider.notifier);

        if (selection.lat != null && selection.lng != null) {
          notifier.setLocation(
            type: widget.type,
            label: selection.label,
            lat: selection.lat!,
            lng: selection.lng!,
          );
        }

        widget.onSelected?.call(selection.label, selection.lat, selection.lng);
      },

      fieldViewBuilder: (_, controller, focusNode, __) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) {
            notifier.search(value, fieldType: widget.type);
          },
          decoration: InputDecoration(
            hintText: "Enter location",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(
              Icons.location_on,
              color: widget.type == LocationFieldType.source
                  ? Colors.green
                  : Colors.red,
            ),
            suffixIcon: asyncSuggestions.when(
              loading: () => isActiveField
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const SizedBox.shrink(),
              data: (_) => controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        notifier.clear();
                      },
                    )
                  : const SizedBox.shrink(),
              error: (_, __) => const Icon(Icons.error_outline),
            ),
          ),
        );
      },

      optionsViewBuilder: (context, onSelected, options) {
        final suggestions = options.toList();

        if (suggestions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              child: OverlaySuggestionList(
                suggestions: suggestions,
                onSelected: onSelected,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
