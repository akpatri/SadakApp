import 'package:open_route_service/open_route_service.dart';

abstract class IORSOptimization {
  Future<OptimizationData> optimizationDataPost({
    required List<VroomJob> jobs,
    required List<VroomVehicle> vehicles,
    List<dynamic>? matrix,
    Object? options,
  });
}
