import 'package:open_route_service/open_route_service.dart';

abstract class IORSMatrix {
  Future<TimeDistanceMatrix> matrixPost({
    required List<ORSCoordinate> locations,
    List<int>? destinations,
    String? id,
    List<String> metrics = const <String>['duration'],
    List<dynamic>? metricsStrings,
    bool resolveLocations = false,
    List<int>? sources,
    String units = 'm',
    ORSProfile? profileOverride,
  });
}
