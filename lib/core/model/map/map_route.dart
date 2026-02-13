import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';

/// ===============================================================
/// AGGREGATED ROUTE (Multi-Segment Support)
/// ===============================================================

class MapRoute {
  final double totalDistanceMeters;
  final double totalDurationSeconds;
  final double totalCost;
  final List<MapRouteSegment> segments;
  final List<LatLng> fullGeometry;

  const MapRoute({
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.totalCost,
    required this.segments,
    required this.fullGeometry,
  });
}


