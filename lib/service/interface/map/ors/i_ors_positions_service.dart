import 'package:open_route_service/open_route_service.dart';

abstract class IORSPois {
  Future<PoisData> poisDataPost({
    required String request,
    Object? geometry,
    Object? filters,
    int? limit,
    String? sortBy,
  });
}
