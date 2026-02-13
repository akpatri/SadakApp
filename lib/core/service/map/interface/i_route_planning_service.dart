import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';

abstract class IRoutePlanningService {
  /// AI-powered route planning
  Future<MapRoute> buildRouteFromPrompt({
    required String prompt,
    required LatLng source,
    required List<LatLng> destinations,
  });

  /// Pure deterministic routing (no AI involved)
  Future<MapRoute> buildDeterministicRoute({
    required LatLng source,
    required List<LatLng> destinations,
    required TransportProfile profile,
  });
}
