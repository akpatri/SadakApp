import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/model/map/multi_segment_route_model.dart';
import 'package:sadak/model/map/route_comment.dart';
import 'package:sadak/model/map/route_source_enum.dart';

abstract class RouteRepository {
  Future<MultiSegmentRoute> createRoute({
    required List<ORSCoordinate> waypoints,
    required ORSProfile profile,
    required RouteSource source,
    String? userId,
  });

  Future<void> vote(String routeId, double value);
  Future<void> addComment(RouteComment comment);

  Stream<List<MultiSegmentRoute>> watchRoutes();
  Stream<List<RouteComment>> watchComments(String routeId);
}
