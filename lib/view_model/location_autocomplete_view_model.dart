import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/view/location_suggestion_model.dart';
import 'package:sadak/view/home/widget/location_autocomplete_fied.dart';

class LocationAutocompleteNotifier
    extends AsyncNotifier<List<LocationSuggestion>> {
  Timer? _debounce;
  ORSCoordinate? _sourceCoordinate;
  ORSCoordinate? _destinationCoordinate;
  bool get hasBothCoordinates =>
      _sourceCoordinate != null && _destinationCoordinate != null;
  ORSCoordinate? get sourceCoordinate => _sourceCoordinate;
  ORSCoordinate? get destinationCoordinate => _destinationCoordinate;
  @override
  Future<List<LocationSuggestion>> build() async {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return [];
  }

  // ----------------------------------------------------------
  // SEARCH
  // ----------------------------------------------------------

  Future<void> search(String text) async {
    if (text.trim().length < 3) {
      state = const AsyncData([]);
      return;
    }

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(text);
    });
  }

  Future<void> _performSearch(String text) async {
    try {
      state = const AsyncLoading();

      final service = ref.read(geoCodingServiceProvider);

      final result = await service.geocodeAutoCompleteGet(
        text: text,
        focusPointCoordinate: _sourceCoordinate, // bias near source
      );

      final features = result.features ?? [];

      final suggestions = features.take(5).map((feature) {
        final coords = feature.geometry.coordinates;

        double? lat;
        double? lng;

        if (coords.isNotEmpty && coords.first.isNotEmpty) {
          final coord = coords.first.first;
          lat = coord.latitude;
          lng = coord.longitude;
        }

        return LocationSuggestion(
          label: (feature.properties['label'] as String?) ?? "",
          lat: lat,
          lng: lng,
        );
      }).toList();

      state = AsyncData(suggestions);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ----------------------------------------------------------
  // SET SELECTED LOCATION
  // ----------------------------------------------------------

  void setLocation({
    required LocationFieldType type,
    required String label,
    required double lat,
    required double lng,
  }) {
    final coordinate = ORSCoordinate(latitude: lat, longitude: lng);
    state = const AsyncData([]);

    if (type == LocationFieldType.source) {
      _sourceCoordinate = coordinate;
    } else {
      _destinationCoordinate = coordinate;
    }
  }

  // ----------------------------------------------------------
  // CLEAR
  // ----------------------------------------------------------

  void clear() {
    _debounce?.cancel();
    state = const AsyncData([]);
  }

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------
}
