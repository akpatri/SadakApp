import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/extension/geo_json_feature_copy.dart';
import 'package:sadak/model/geo_json_property_model.dart';

class GeoJsonCollectionNotifier
    extends AsyncNotifier<GeoJsonFeatureCollection> {
  @override
  Future<GeoJsonFeatureCollection> build() async {
    // Initial empty state
    return const GeoJsonFeatureCollection(bbox: [], features: []);
  }

  void upsertFeature({
    required GeoJsonFeature feature,
    required String markerType,
  }) {
    final current = state.value;
    if (current == null) return;

    final updatedFeatures = [
      ...current.features.where((f) {
        final prop = GeoJsonProperty.fromDynamic(f.properties);
        return prop?.type != markerType;
      }),
      feature,
    ];

    final newBbox = _calculateBbox(updatedFeatures);

    state = AsyncData(
      GeoJsonFeatureCollection(bbox: newBbox, features: updatedFeatures),
    );
  }

  List<ORSCoordinate> _calculateBbox(List<GeoJsonFeature> features) {
    final allCoords = <ORSCoordinate>[];

    for (final feature in features) {
      for (final ring in feature.geometry.coordinates) {
        allCoords.addAll(ring);
      }
    }

    if (allCoords.isEmpty) return [];

    double minLat = allCoords.first.latitude;
    double maxLat = allCoords.first.latitude;
    double minLng = allCoords.first.longitude;
    double maxLng = allCoords.first.longitude;

    for (final c in allCoords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    return [
      ORSCoordinate(latitude: minLat, longitude: minLng),
      ORSCoordinate(latitude: maxLat, longitude: maxLng),
    ];
  }

  Future<void> setCurrentLocationAsSource() async {
    final service = ref.read(locationServiceProvider);

    final current = await service.getCurrentPosition();

    final feature = current.features.first;

    upsertFeature(feature: feature, markerType: "source");
  }

  Future<void> setCollection(
    Future<GeoJsonFeatureCollection> futureCollection,
  ) async {
    state = const AsyncLoading();

    try {
      final collection = await futureCollection;
      state = AsyncData(collection);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void clear() {
    state = const AsyncData(GeoJsonFeatureCollection(bbox: [], features: []));
  }
}
