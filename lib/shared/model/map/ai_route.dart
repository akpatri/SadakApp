import 'package:sadak/shared/model/map/transport_file_enum.dart';

class AIRouteIntent {
  final List<AIRouteLegIntent> legs;
  final bool optimizeRemaining;
  final String? explanation;
  final double? confidence;

  const AIRouteIntent({
    required this.legs,
    required this.optimizeRemaining,
    this.explanation,
    this.confidence,
  });

  factory AIRouteIntent.fromJson(Map<String, dynamic> json) {
    return AIRouteIntent(
      legs: (json['legs'] as List)
          .map((e) => AIRouteLegIntent.fromJson(e))
          .toList(),
      optimizeRemaining: json['opt'] ?? false,
      explanation: json['note'],
      confidence: (json['conf'] as num?)?.toDouble(),
    );
  }
}

class AIRouteLegIntent {
  final int fromIndex;
  final int toIndex;
  final TransportProfile profile;

  const AIRouteLegIntent({
    required this.fromIndex,
    required this.toIndex,
    required this.profile,
  });

  factory AIRouteLegIntent.fromJson(Map<String, dynamic> json) {
    return AIRouteLegIntent(
      fromIndex: json['f'],
      toIndex: json['t'],
      profile: TransportProfile.fromString(json['m']),
    );
  }
}
