import 'package:open_route_service/open_route_service.dart';

abstract class IORSIsochrones {
  Future<GeoJsonFeatureCollection> isochronesPost({
    required List<ORSCoordinate> locations,
    required List<int> range,
    List<String> attributes = const <String>[],
    String? id,
    bool intersections = false,
    int? interval,
    String locationType = 'start',
    Map<String, dynamic>? options,
    String rangeType = 'time',
    int? smoothing,
    String areaUnits = 'm',
    String units = 'm',
    ORSProfile? profileOverride,
  });
}
