import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/view/home/widget/location_autocomplete_fied.dart';

class FloatingCurrentLocationButton extends ConsumerWidget {
  const FloatingCurrentLocationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _loadCurrentLocation(context, ref),
      backgroundColor: Theme.of(context).primaryColor,
      tooltip: 'Use current location',
      child: const Icon(Icons.my_location),
    );
  }

  Future<void> _loadCurrentLocation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      // Show loading indicator
      if (!context.mounted) return;

      final locationService = ref.read(locationServiceProvider);
      final current = await locationService.getCurrentPosition();

      if (!context.mounted) return;

      final label =
          current.features.first.properties['label'] ?? "Current Location";
      final coord = current.features.first.geometry.coordinates.first.first;

      // Update the notifier with current location
      ref.read(locationAutocompleteProvider.notifier).setLocation(
            type: LocationFieldType.source,
            label: label,
            lat: coord.latitude,
            lng: coord.longitude,
          );

      // Show success message
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 Location set to: $label'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
