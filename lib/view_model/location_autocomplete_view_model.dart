import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/geo_json_property_model.dart';
import 'package:sadak/model/map/location_suggesstion_model.dart';
import 'package:sadak/view/home/widget/location_autocomplete_fied.dart';

class LocationAutocompleteNotifier
    extends AsyncNotifier<List<LocationSuggestion>> {
  Timer? _debounce;
  LocationFieldType? _activeSearchFieldType;

  LocationFieldType? get activeSearchFieldType => _activeSearchFieldType;

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

  Future<void> search(String text, {LocationFieldType? fieldType}) async {
    _activeSearchFieldType = fieldType;

    final query = text.trim();

    if (query.length < 3) {
      state = const AsyncData([]);
      return;
    }

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String text) async {
    try {
      state = const AsyncLoading();

      final service = ref.read(geoCodingServiceProvider);

      // Read bias from GeoJson
      final geoJson = ref.read(geoJsonCollectionProvider).value;
      ORSCoordinate? sourceCoordinate;

      if (geoJson != null) {
        for (final feature in geoJson.features) {
          if (feature.properties["markerType"] == "source") {
            final coords = feature.geometry.coordinates;
            if (coords.isNotEmpty && coords.first.isNotEmpty) {
              sourceCoordinate = coords.first.first;
            }
            break;
          }
        }
      }

      final result = await service.geocodeAutoCompleteGet(
        text: text,
        focusPointCoordinate: sourceCoordinate,
      );

      final suggestions = (result.features ?? []).take(5).map((feature) {
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
    // Clear suggestions
    state = const AsyncData([]);

    final feature = GeoJsonFeature(
      type: "Feature",
      properties: GeoJsonProperty(
        id: type.name,
        type: type.name,
        isVisible: true,
        label: label,
      ).toJson(),
      geometry: GeoJsonFeatureGeometry(
        type: "Point",
        internalType: GsonFeatureGeometryCoordinatesType.single,
        coordinates: [
          [ORSCoordinate(latitude: lat, longitude: lng)],
        ],
      ),
    );

    ref
        .read(geoJsonCollectionProvider.notifier)
        .upsertFeature(feature: feature, markerType: type.name);
  }

  // ----------------------------------------------------------
  // CLEAR
  // ----------------------------------------------------------

  void clear() {
    _debounce?.cancel();
    state = const AsyncData([]);
  }
}
