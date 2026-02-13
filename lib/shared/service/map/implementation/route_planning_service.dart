import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/ai_context.dart';
import 'package:sadak/shared/model/map/ai_route.dart';
import 'package:sadak/shared/model/map/map_route.dart';
import 'package:sadak/shared/model/map/map_route_segment_request.dart';
import 'package:sadak/shared/model/map/transport_file_enum.dart';
import 'package:sadak/shared/service/map/interface/i_ai_engine.dart';
import 'package:sadak/shared/service/map/interface/i_map_service.dart';
import 'package:sadak/shared/service/map/interface/i_route_planning_service.dart';

class RoutePlanningService implements IRoutePlanningService {
  final IAIEngine aiEngine;
  final IMapService mapService;

  RoutePlanningService({required this.aiEngine, required this.mapService});

  // ============================================================
  // AI ROUTE
  // ============================================================

  @override
  Future<MapRoute> buildRouteFromPrompt({
    required String prompt,
    required LatLng source,
    required List<LatLng> destinations,
  }) async {
    if (destinations.isEmpty) {
      throw ArgumentError('Destinations cannot be empty');
    }

    final context = AIContext(source: source, destinations: destinations);

    final intent = await aiEngine.planRoute(prompt: prompt, context: context);

    _validateIntent(intent, destinations.length);

    // Optional safety fallback
    if ((intent.confidence ?? 1.0) < 0.4) {
      return buildDeterministicRoute(
        source: source,
        destinations: destinations,
        profile: TransportProfile.driving,
      );
    }

    return _buildFromIntent(intent, source, destinations);
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  void _validateIntent(AIRouteIntent intent, int maxIndex) {
    for (final leg in intent.legs) {
      if (leg.fromIndex < -1 ||
          leg.fromIndex >= maxIndex ||
          leg.toIndex < 0 ||
          leg.toIndex >= maxIndex) {
        throw Exception('Invalid AI index reference');
      }
    }
  }

  // ============================================================
  // BUILD FROM AI INTENT
  // ============================================================

  Future<MapRoute> _buildFromIntent(
    AIRouteIntent intent,
    LatLng source,
    List<LatLng> destinations,
  ) async {
    final List<MapRouteSegmentRequest> requests = [];

    for (final leg in intent.legs) {
      final from = leg.fromIndex == -1 ? source : destinations[leg.fromIndex];

      final to = destinations[leg.toIndex];

      requests.add(
        MapRouteSegmentRequest(start: from, end: to, profile: leg.profile),
      );
    }

    return mapService.getMultiSegmentRoute(segments: requests);
  }

  // ============================================================
  // DETERMINISTIC ROUTE (NO AI)
  // ============================================================

  @override
  Future<MapRoute> buildDeterministicRoute({
    required LatLng source,
    required List<LatLng> destinations,
    required TransportProfile profile,
  }) async {
    if (destinations.isEmpty) {
      throw ArgumentError('Destinations cannot be empty');
    }

    final coordinates = [source, ...destinations];

    final routes = await mapService.getDirections(
      coordinates: coordinates,
      profile: profile,
    );

    if (routes.isEmpty) {
      throw Exception('No route found');
    }

    // Use primary route (index 0)
    return routes.first;
  }
}
