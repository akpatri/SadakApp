import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';
import 'package:sadak/core/model/map/map_route_segment_request.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/model/map/map_distance_matrix.dart';

/// ===============================================================
/// CLEAN & BALANCED MAP SERVICE CONTRACT
/// Open for extension, closed for modification
/// ===============================================================

abstract class IMapService {
  // =============================================================
  // GEOCODING
  // =============================================================

  Future<List<MapPlace>> searchPlaces({
    required String query,
    required LatLng near,
    int limit = 5,
  });

  Future<MapPlace?> reverseGeocode(LatLng location);

  Future<List<MapPlace>> reverseGeocodeBatch({
    required List<LatLng> locations,
  });

  // =============================================================
  // ROUTING
  // =============================================================

  Future<List<MapRoute>> getDirections({
    required List<LatLng> coordinates,
    required TransportProfile profile,
    bool alternatives = false,
  });

  Future<MapRoute> getMultiSegmentRoute({
    required List<MapRouteSegmentRequest> segments,
  });

  Future<MapRouteSegment> recalculateSegment({
    required LatLng start,
    required LatLng end,
    required TransportProfile profile,
  });

  Future<MapRoute> optimizeWaypointOrder({
    required List<LatLng> waypoints,
    required TransportProfile profile,
  });

  Future<bool> isRouteReachable({
    required LatLng start,
    required LatLng end,
    required TransportProfile profile,
  });

  // =============================================================
  // DISTANCE MATRIX
  // =============================================================

  Future<MapDistanceMatrix> getDistanceMatrix({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    required TransportProfile profile,
  });

  // =============================================================
  // ROAD SNAPPING
  // =============================================================

  Future<LatLng> snapToRoad({
    required LatLng location,
    required TransportProfile profile,
  });

  // =============================================================
  // COST ESTIMATION
  // =============================================================

  double estimateCost({
    required double distanceMeters,
    required TransportProfile profile,
  });

  // =============================================================
  // CACHE CONTROL
  // =============================================================

  void clearCache();
}
