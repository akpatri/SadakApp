import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';

/// ===============================================================
/// ROUTE SEGMENT (OUTPUT)
/// ===============================================================

class MapRouteSegment {
  final TransportProfile profile;
  final double distanceMeters;
  final double durationSeconds;
  final double cost;
  final List<LatLng> geometry;

  const MapRouteSegment({
    required this.profile,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.cost,
    required this.geometry,
  });
}
