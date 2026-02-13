import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/map_route.dart';
import 'package:sadak/shared/model/map/map_route_segment_request.dart';
import 'package:sadak/shared/model/map/transport_file_enum.dart';

abstract class IRouteRepository {
  Future<MapRoute> fetchPrimaryRoute({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  });

  Future<List<MapRoute>> fetchAlternativeRoutes({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  });

  Future<MapRoute> buildMultiSegmentRoute({
    required List<MapRouteSegmentRequest> segments,
  });
}
