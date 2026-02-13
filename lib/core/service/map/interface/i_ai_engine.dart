import 'package:sadak/core/model/AI/ai_context.dart';
import 'package:sadak/core/model/AI/ai_route.dart';

/// Defines the contract for an AI-powered routing engine.
///
/// Implementations of [IAIEngine] are responsible for interpreting
/// a natural language [prompt] and transforming it into a structured
/// [AIRouteIntent] using the provided [AIContext].
///
/// This abstraction allows different AI providers (e.g., local models,
/// cloud-based LLMs, or rule-based systems) to be used interchangeably
/// without affecting the rest of the application.
///
/// Example usage:
/// ```dart
/// final intent = await aiEngine.planRoute(
///   prompt: "Plan a scenic bike route avoiding highways",
///   context: aiContext,
/// );
/// ```
///
/// The returned [AIRouteIntent] should contain all extracted routing
/// preferences such as transport profile, waypoints, constraints,
/// and optimization goals.
abstract class IAIEngine {
  /// Analyzes a natural language [prompt] and generates a structured
  /// [AIRouteIntent] based on the provided [AIContext].
  ///
  /// Parameters:
  /// - [prompt]: A user-provided natural language instruction describing
  ///   routing preferences, constraints, or goals.
  /// - [context]: Additional contextual data that may influence planning,
  ///   such as current location, user preferences, historical behavior,
  ///   or available transport profiles.
  ///
  /// Returns:
  /// A [Future] that resolves to an [AIRouteIntent] containing the parsed
  /// and structured routing instructions.
  ///
  /// Throws:
  /// - [Exception] if the AI engine fails to process the request.
  /// - Implementation-specific errors for networking, parsing,
  ///   or model inference failures.
  Future<AIRouteIntent> planRoute({
    required String prompt,
    required AIContext context,
  });
}
