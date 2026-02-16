import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class MapViewModel extends AsyncNotifier<GeoJsonFeatureCollection> {
  LatLngBounds? bounds;

  late ORSCoordinate _start;
  late ORSCoordinate _end;

  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<Polygon> _polygons = [];

  /// ==========================================================
  /// INITIALIZE
  /// ==========================================================

  Future<void> initialize({
    required ORSCoordinate startCoordinate,
    required ORSCoordinate endCoordinate,
    required GeoJsonFeatureCollection collection,
  }) async {
    state = const AsyncLoading();

    _start = startCoordinate;
    _end = endCoordinate;

    _markers = [];
    _polylines = [];
    _polygons = [];

    final allPoints = <LatLng>[];

    for (final feature in collection.features) {
      final geometry = feature.geometry;

      switch (geometry.internalType) {
        /// ---------------- POINT ----------------
        case GsonFeatureGeometryCoordinatesType.single:
          final coord = geometry.coordinates.first.first;
          final latLng = LatLng(coord.latitude, coord.longitude);

          _markers.add(
            Marker(
              point: latLng,
              width: 40,
              height: 40,
              child: Tooltip(
                message: feature.properties.toString(),
                child: const Icon(Icons.location_on, color: Colors.red),
              ),
            ),
          );

          allPoints.add(latLng);
          break;

        /// ---------------- LINESTRING ----------------
        case GsonFeatureGeometryCoordinatesType.list:
          if (geometry.type == "LineString") {
            final points = geometry.coordinates.first
                .map((c) => LatLng(c.latitude, c.longitude))
                .toList();

            if (points.length >= 2) {
              _polylines.add(
                Polyline(
                  points: points,
                  strokeWidth: 5,
                  color: _resolvePolylineColor(feature.properties),
                ),
              );

              allPoints.addAll(points);
            }
          }
          break;

        /// ---------------- POLYGON ----------------
        case GsonFeatureGeometryCoordinatesType.listList:
          if (geometry.type == "Polygon") {
            for (final ring in geometry.coordinates) {
              final points = ring
                  .map((c) => LatLng(c.latitude, c.longitude))
                  .toList();

              if (points.length >= 3) {
                _polygons.add(
                  Polygon(
                    points: points,
                    color: Colors.blue.withOpacity(0.2),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                );

                allPoints.addAll(points);
              }
            }
          }
          break;

        case GsonFeatureGeometryCoordinatesType.empty:
          break;
      }
    }

    /// Add start / end
    final startLatLng = LatLng(_start.latitude, _start.longitude);
    final endLatLng = LatLng(_end.latitude, _end.longitude);

    _markers.addAll([
      Marker(
        point: startLatLng,
        width: 50,
        height: 50,
        child: const Icon(Icons.flag, color: Colors.green),
      ),
      Marker(
        point: endLatLng,
        width: 50,
        height: 50,
        child: const Icon(Icons.flag, color: Colors.black),
      ),
    ]);

    allPoints.add(startLatLng);
    allPoints.add(endLatLng);

    /// Compute bounds
    if (allPoints.isNotEmpty) {
      bounds = LatLngBounds.fromPoints(allPoints);
    }

    state = AsyncData(collection);
  }

  /// ==========================================================
  /// BUILD (SAFE)
  /// ==========================================================

  @override
  Future<GeoJsonFeatureCollection> build() async {
    return const GeoJsonFeatureCollection(bbox: [], features: []);
  }

  /// ==========================================================
  /// PUBLIC GETTERS (UI USES ONLY THESE)
  /// ==========================================================

  List<Marker> get markers => _markers;

  List<Polyline> get polylines => _polylines;

  List<Polygon> get polygons => _polygons;

  /// ==========================================================
  /// STYLE RESOLVER
  /// ==========================================================

  Color _resolvePolylineColor(Map<String, dynamic> properties) {
    final type = properties["type"];

    if (type == "route") return Colors.blue;
    if (type == "walk") return Colors.green;
    if (type == "danger") return Colors.red;

    return Colors.orange;
  }
}
