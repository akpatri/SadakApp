import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/view/location_suggestion_model.dart';
import 'package:sadak/view_model/location_autocomplete_view_model.dart';

class AllOptionsButton extends ConsumerWidget {
  const AllOptionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 Watch state for rebuild
    ref.watch(locationAutocompleteProvider);

    // 👇 Read notifier for coordinates
    final notifier =
        ref.read(locationAutocompleteProvider.notifier);

    final source = notifier.sourceCoordinate;
    final destination = notifier.destinationCoordinate;

    final isEnabled = source != null && destination != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                context.pushNamed(
                  'routeList',
                  extra: {
                    'source': source!,
                    'destination': destination!,
                  },
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "All Options",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



@Preview(name: "All Options Button - Enabled")
Widget buttonPreview() {
  return ProviderScope(
    overrides: [
      locationAutocompleteProvider.overrideWith(
        () => _MockLocationNotifier(),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: AllOptionsButton(),
          ),
        ),
      ),
    ),
  );
}
class _MockLocationNotifier
    extends LocationAutocompleteNotifier {

  @override
  Future<List<LocationSuggestion>> build() async {
    return [];
  }

  @override
  ORSCoordinate? get sourceCoordinate =>
      const ORSCoordinate(latitude: 12.0, longitude: 77.0);

  @override
  ORSCoordinate? get destinationCoordinate =>
      const ORSCoordinate(latitude: 13.0, longitude: 78.0);
}


@Preview(name: "All Options Button - Disabled")
Widget buttonDisabledPreview() {
  return ProviderScope(
    overrides: [
      locationAutocompleteProvider.overrideWith(
        () => _MockDisabledNotifier(),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: AllOptionsButton(),
          ),
        ),
      ),
    ),
  );
}

class _MockDisabledNotifier
    extends LocationAutocompleteNotifier {

  @override
  Future<List<LocationSuggestion>> build() async {
    return [];
  }

  @override
  ORSCoordinate? get sourceCoordinate => null;

  @override
  ORSCoordinate? get destinationCoordinate => null;
}
