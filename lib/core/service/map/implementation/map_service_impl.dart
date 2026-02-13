import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';
import 'package:sadak/core/model/map/map_route_segment_request.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/model/map/map_distance_matrix.dart';
import 'package:sadak/core/service/map/extensions/map/ors_map_service_extension.dart';
import '../interface/i_map_service.dart';

class MapServiceImpl implements IMapService {
  final Dio dio;
  final String apiKey;

  MapServiceImpl({required this.dio, required this.apiKey});

  @override
  void clearCache() {
    // TODO: implement clearCache
  }

  @override
  double estimateCost({
    required double distanceMeters,
    required TransportProfile profile,
  }) {
    // TODO: implement estimateCost
    final double distanceKm = distanceMeters / 1000;

    // Average speeds (km/h) for time-based services
    const Map<TransportProfile, double> avgSpeed = {
      TransportProfile.driving: 40,
      TransportProfile.cycling: 15,
      TransportProfile.walking: 5,
      TransportProfile.bikeSharing: 18,
      TransportProfile.bus: 30,
      TransportProfile.train: 70,
    };

    switch (profile) {
      case TransportProfile.driving:
        const double baseFare = 2.5;
        const double perKmRate = 1.2;
        const double minimumFare = 4.0;

        final cost = baseFare + (distanceKm * perKmRate);
        return cost < minimumFare ? minimumFare : cost;

      case TransportProfile.cycling:
        // Personal cycling assumed free
        return 0.0;

      case TransportProfile.walking:
        // Walking is free
        return 0.0;

      case TransportProfile.bikeSharing:
        const double unlockFee = 1.0;
        const double perMinuteRate = 0.15;
        const double minimumFare = 1.5;

        final speed = avgSpeed[profile]!;
        final durationMinutes = (distanceKm / speed) * 60;

        final cost = unlockFee + (durationMinutes * perMinuteRate);
        return cost < minimumFare ? minimumFare : cost;

      case TransportProfile.bus:
        const double baseFare = 1.5;
        const double perKmRate = 0.2;

        final cost = baseFare + (distanceKm * perKmRate);
        return cost;

      case TransportProfile.train:
        if (distanceKm <= 10) {
          return 2.0;
        } else if (distanceKm <= 50) {
          return 5.0;
        } else {
          return 10.0 + ((distanceKm - 50) * 0.1);
        }
      case TransportProfile.ferry:
        // Ferry usually has base boarding fee + per km charge
        if (distanceKm <= 5) {
          return 3.0; // short crossing base fare
        } else if (distanceKm <= 20) {
          return 6.0;
        } else {
          return 8.0 + ((distanceKm - 20) * 0.15);
        }
        
      default:
        // Safe fallback pricing (generic motorized transport)
        return distanceKm * 0.2;
    }
  }

  @override
  Future<List<MapRoute>> getDirections({
    required List<LatLng> coordinates,
    required TransportProfile profile,
    bool alternatives = false,
  }) {
    return getDirectionsFromORS(
      coordinates: coordinates,
      profile: profile,
      alternatives: alternatives,
    );
  }

  @override
  Future<MapRoute> getMultiSegmentRoute({
    required List<MapRouteSegmentRequest> segments,
  }) async {
    if (segments.isEmpty) {
      throw ArgumentError('At least one segment is required');
    }

    final List<MapRouteSegment> computedSegments = [];

    double totalDistance = 0;
    double totalDuration = 0;
    double totalCost = 0;

    final List<LatLng> fullGeometry = [];

    for (int i = 0; i < segments.length; i++) {
      final request = segments[i];

      final segment = await recalculateSegment(
        start: request.start,
        end: request.end,
        profile: request.profile,
      );

      computedSegments.add(segment);

      totalDistance += segment.distanceMeters;
      totalDuration += segment.durationSeconds;
      totalCost += segment.cost;

      // Avoid duplicate geometry join point
      if (i == 0) {
        fullGeometry.addAll(segment.geometry);
      } else {
        if (segment.geometry.isNotEmpty) {
          fullGeometry.addAll(segment.geometry.skip(1));
        }
      }
    }

    return MapRoute(
      totalDistanceMeters: totalDistance,
      totalDurationSeconds: totalDuration,
      totalCost: totalCost,
      segments: computedSegments,
      fullGeometry: fullGeometry,
    );
  }

  @override
  Future<MapRouteSegment> recalculateSegment({
    required LatLng start,
    required LatLng end,
    required TransportProfile profile,
  }) async {
    final routes = await getDirections(
      coordinates: [start, end],
      profile: profile,
      alternatives: false,
    );

    if (routes.isEmpty) {
      throw Exception('No route found between given points');
    }

    final primaryRoute = routes.first;

    final distance = primaryRoute.totalDistanceMeters;
    final duration = primaryRoute.totalDurationSeconds;

    final cost = estimateCost(distanceMeters: distance, profile: profile);

    return MapRouteSegment(
      profile: profile,
      distanceMeters: distance,
      durationSeconds: duration,
      cost: cost,
      geometry: primaryRoute.fullGeometry,
    );
  }

  @override
  Future<MapPlace?> reverseGeocode(LatLng location) {
    return reverseGeocodeFromORS(location);
  }

  @override
  Future<List<MapPlace>> searchPlaces({
    required String query,
    required LatLng near,
    int limit = 5,
  }) {
    return searchPlacesFromORS(query: query, near: near, limit: limit);
  }

  @override
  Future<bool> isRouteReachable({
    required LatLng start,
    required LatLng end,
    required TransportProfile profile,
  }) async {
    try {
      final segment = await recalculateSegment(
        start: start,
        end: end,
        profile: profile,
      );

      return segment.distanceMeters > 0 &&
          segment.durationSeconds > 0 &&
          segment.geometry.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<MapRoute> optimizeWaypointOrder({
    required List<LatLng> waypoints,
    required TransportProfile profile,
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('At least 2 waypoints required');
    }

    // Fetch full distance matrix
    final matrix = await getDistanceMatrix(
      origins: waypoints,
      destinations: waypoints,
      profile: profile,
    );

    final List<int> remaining = List.generate(waypoints.length, (i) => i);

    final List<int> optimizedOrder = [];

    // Keep first waypoint fixed
    int currentIndex = remaining.removeAt(0);
    optimizedOrder.add(currentIndex);

    while (remaining.isNotEmpty) {
      double minDistance = double.infinity;
      int nextIndex = remaining.first;

      for (final candidate in remaining) {
        final distance = matrix.getDistance(currentIndex, candidate);

        if (distance < minDistance) {
          minDistance = distance;
          nextIndex = candidate;
        }
      }

      optimizedOrder.add(nextIndex);
      remaining.remove(nextIndex);
      currentIndex = nextIndex;
    }

    // Build segment requests
    final List<MapRouteSegmentRequest> segments = [];

    for (int i = 0; i < optimizedOrder.length - 1; i++) {
      segments.add(
        MapRouteSegmentRequest(
          start: waypoints[optimizedOrder[i]],
          end: waypoints[optimizedOrder[i + 1]],
          profile: profile,
        ),
      );
    }

    return getMultiSegmentRoute(segments: segments);
  }

  @override
  Future<List<MapPlace>> reverseGeocodeBatch({
    required List<LatLng> locations,
  }) async {
    if (locations.isEmpty) {
      return [];
    }

    final futures = locations.map((location) async {
      try {
        return await reverseGeocode(location);
      } catch (_) {
        return null;
      }
    });

    final results = await Future.wait(futures);

    // Remove nulls (failed lookups)
    return results.whereType<MapPlace>().toList();
  }

  @override
  Future<LatLng> snapToRoad({
    required LatLng location,
    required TransportProfile profile,
  }) {
    return snapToRoadFromORS(location: location, profile: profile);
  }

  @override
  @override
  Future<MapDistanceMatrix> getDistanceMatrix({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    required TransportProfile profile,
  }) {
    return getDistanceMatrixFromORS(
      origins: origins,
      destinations: destinations,
      profile: profile,
    );
  }
}
