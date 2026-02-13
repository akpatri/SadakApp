import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/service/map/interface/i_community_route_service.dart';

abstract class ICommunityRepository {
  Future<CommunityRoute> submitRoute(CommunityRoute route);

  Future<void> deleteRoute({
    required String routeId,
    required String requesterId,
  });

  Future<List<CommunityRoute>> fetchRoutes({
    required LatLng start,
    required LatLng end,
  });
}
