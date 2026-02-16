import 'package:open_route_service/open_route_service.dart';

abstract class SegmentCache {
  Future<DirectionRouteData?> get(String key);
  Future<void> save(String key, DirectionRouteData data);
}
