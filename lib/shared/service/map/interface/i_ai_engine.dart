import 'package:sadak/shared/model/map/ai_context.dart';
import 'package:sadak/shared/model/map/ai_route.dart';


abstract class IAIEngine {
  Future<AIRouteIntent> planRoute({
    required String prompt,
    required AIContext context,
  });
}
