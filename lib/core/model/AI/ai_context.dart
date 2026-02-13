import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/AI/ai_constraint.dart';

class AIContext {
  final LatLng source;
  final List<LatLng> destinations;
  final AIConstraints? constraints;

  const AIContext({
    required this.source,
    required this.destinations,
    this.constraints,
  });
}
