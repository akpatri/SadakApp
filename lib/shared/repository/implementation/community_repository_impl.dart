import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/repository/interface/i_community_repository.dart';
import 'package:sadak/shared/service/map/interface/i_community_route_service.dart';

class CommunityRepositoryImpl implements ICommunityRepository{
  @override
  Future<void> deleteRoute({required String routeId, required String requesterId}) {
    // TODO: implement deleteRoute
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityRoute>> fetchRoutes({required LatLng start, required LatLng end}) {
    // TODO: implement fetchRoutes
    throw UnimplementedError();
  }

  @override
  Future<CommunityRoute> submitRoute(CommunityRoute route) {
    // TODO: implement submitRoute
    throw UnimplementedError();
  }

}