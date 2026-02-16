import 'package:open_route_service/open_route_service.dart';

abstract class ILocationService {
  Future<PoisData> getCurrentPosition();

}
