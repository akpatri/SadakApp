import 'package:equatable/equatable.dart';

/// AI-generated description for a route
/// Provides human-readable journey details like "Take bus #45 from downtown..."
class RouteDescription extends Equatable {
  final String routeId;
  final String description;           // Full description (e.g., "Take bus #45 for 15 min, then walk 5 min to...")
  final String summary;               // Short one-liner (e.g., "Bus + Walk (20 min)")
  final DateTime generatedAt;
  final String? generatedBy;          // 'huggingface' or other source

  const RouteDescription({
    required this.routeId,
    required this.description,
    required this.summary,
    required this.generatedAt,
    this.generatedBy,
  });

  @override
  List<Object?> get props => [
    routeId,
    description,
    summary,
    generatedAt,
    generatedBy,
  ];

  /// Create copy with modified fields
  RouteDescription copyWith({
    String? routeId,
    String? description,
    String? summary,
    DateTime? generatedAt,
    String? generatedBy,
  }) {
    return RouteDescription(
      routeId: routeId ?? this.routeId,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
    );
  }
}
