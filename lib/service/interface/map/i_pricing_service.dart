import 'package:open_route_service/open_route_service.dart';

abstract class IPricingService {
  double calculate({
    required double distance,
    required double duration,
    required ORSProfile profile,
  });
}
