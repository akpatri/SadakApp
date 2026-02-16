import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/view/location_suggestion_model.dart';
import 'package:flutter/widget_previews.dart';
import 'package:sadak/view/home/widget/overlay_suggestion_list.dart';


enum LocationFieldType { source, destination }

class LocationAutocompleteField extends ConsumerStatefulWidget {
  final LocationFieldType type;
  final Function(String, double?, double?)? onSelected;

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
    final locationService = ref.read(locationServiceProvider);

    final current = await locationService.getCurrentPosition();

    final label =
        current.features.first.properties['label'] ?? "Current Location";

    final coord = current.features.first.geometry.coordinates.first.first;

    _controller.text = label;

    widget.onSelected?.call(label, coord.latitude, coord.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final asyncSuggestions = ref.watch(locationAutocompleteProvider);

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
        widget.onSelected?.call(selection.label, selection.lat, selection.lng);
      },

      fieldViewBuilder: (context, textEditingController, focusNode, onSubmit) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) {
            ref.read(locationAutocompleteProvider.notifier).search(value);
          },
          decoration: InputDecoration(
            hintText: "Enter location",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: asyncSuggestions.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              data: (_) => textEditingController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        textEditingController.clear();
                        ref.read(locationAutocompleteProvider.notifier).clear();
                      },
                    )
                  : null,
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

        final parentTheme = Theme.of(context);

        return Theme(
          data: parentTheme.copyWith(
            brightness: Brightness.light, // 👈 FORCE LIGHT MODE
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.white, // 👈 FORCE WHITE BACKGROUND
              elevation: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 48,
                child: OverlaySuggestionList(
                  suggestions: suggestions,
                  query: _controller.text,
                  highlightedIndex: -1,
                  onSelected: (item) {
                    onSelected(item);
                  },
                ),
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

@Preview(name: 'Location Autocomplete - Light')
Widget locationAutocompleteLightPreview() {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Scaffold(
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: LocationAutocompleteField(
              type: LocationFieldType.destination,
            ),
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Location Autocomplete - Dark')
Widget locationAutocompleteDarkPreview() {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: Scaffold(
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: LocationAutocompleteField(
              type: LocationFieldType.destination,
            ),
          ),
        ),
      ),
    ),
  );
}
