import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/map_route.dart';
import 'package:sadak/shared/model/map/map_route_segment_request.dart';
import 'package:sadak/shared/model/map/transport_file_enum.dart';
import 'package:sadak/shared/repository/interface/i_route_repository.dart';

class RouteRepositoryImpl implements IRouteRepository{
  @override
  Future<MapRoute> buildMultiSegmentRoute({required List<MapRouteSegmentRequest> segments}) {
    // TODO: implement buildMultiSegmentRoute
    throw UnimplementedError();
  }

  @override
  Future<List<MapRoute>> fetchAlternativeRoutes({required List<LatLng> coordinates, required TransportProfile profile}) {
    // TODO: implement fetchAlternativeRoutes
    throw UnimplementedError();
  }

  @override
  Future<MapRoute> fetchPrimaryRoute({required List<LatLng> coordinates, required TransportProfile profile}) {
    // TODO: implement fetchPrimaryRoute
    throw UnimplementedError();
  }

}