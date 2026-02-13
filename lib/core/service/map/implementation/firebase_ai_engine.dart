import 'package:cloud_functions/cloud_functions.dart';
import 'package:sadak/core/model/AI/ai_context.dart';
import 'package:sadak/core/model/AI/ai_route.dart';
import 'package:sadak/core/service/map/interface/i_ai_engine.dart';


class FirebaseAIEngine implements IAIEngine {
  final FirebaseFunctions _functions;

  FirebaseAIEngine(this._functions);

  @override
  Future<AIRouteIntent> planRoute({
    required String prompt,
    required AIContext context,
  }) async {
    final callable = _functions.httpsCallable('planRouteAI');

    final response = await callable.call({
      'p': prompt,
      's': [context.source.latitude, context.source.longitude],
      'd': context.destinations
          .map((e) => [e.latitude, e.longitude])
          .toList(),
      'c': context.constraints?.toJson(),
    });

    final data = Map<String, dynamic>.from(response.data);

    return AIRouteIntent.fromJson(data);
  }
}
