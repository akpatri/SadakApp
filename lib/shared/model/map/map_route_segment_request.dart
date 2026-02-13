import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/transport_file_enum.dart';

/// ===============================================================
/// ROUTE SEGMENT REQUEST (INPUT)
/// ===============================================================

class MapRouteSegmentRequest {
  final LatLng start;
  final LatLng end;
  final TransportProfile profile;

  const MapRouteSegmentRequest({
    required this.start,
    required this.end,
    required this.profile,
  });
}







