import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment_request.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';

/// Defines the contract for retrieving and constructing routing data.
///
/// Implementations of [IRouteRepository] are responsible for interacting
/// with external routing providers (e.g., REST APIs) and transforming
/// responses into the application's domain models such as [MapRoute]
/// and related segment entities.
///
/// This abstraction ensures that the domain layer remains independent
/// from specific routing backends and enables easier testing,
/// caching, and provider replacement.
abstract class IRouteRepository {
  /// Fetches the primary (best) route between the given [coordinates]
  /// using the specified [profile].
  ///
  /// Parameters:
  /// - [coordinates]: Ordered list of geographic points representing
  ///   waypoints. The first point is treated as the origin and the last
  ///   as the destination. Intermediate points are treated as stopovers.
  /// - [profile]: The selected [TransportProfile] (e.g., driving,
  ///   cycling, walking) that determines routing behavior and constraints.
  ///
  /// Returns:
  /// A [Future] resolving to a single [MapRoute] representing the
  /// optimal route as determined by the underlying routing provider.
  ///
  /// Throws:
  /// - [Exception] if the route request fails due to network,
  ///   provider, or parsing errors.
  /// - Implementation-specific errors for invalid coordinates
  ///   or unsupported transport profiles.
  Future<MapRoute> fetchPrimaryRoute({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  });

  /// Fetches alternative routes between the given [coordinates]
  /// using the specified [profile].
  ///
  /// Parameters:
  /// - [coordinates]: Ordered list of origin, destination, and
  ///   optional intermediate waypoints.
  /// - [profile]: The selected [TransportProfile] influencing
  ///   route calculation.
  ///
  /// Returns:
  /// A [Future] resolving to a list of [MapRoute] objects representing
  /// viable alternative routes. The list may be empty if no alternatives
  /// are available.
  ///
  /// Notes:
  /// - The primary route may or may not be included in the returned list,
  ///   depending on implementation.
  /// - Alternatives may differ in distance, duration, elevation,
  ///   or road preferences.
  ///
  /// Throws:
  /// - [Exception] for network failures, provider limitations,
  ///   or response parsing errors.
  Future<List<MapRoute>> fetchAlternativeRoutes({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  });

  /// Builds a composite route from multiple pre-defined segments.
  ///
  /// Parameters:
  /// - [segments]: A list of [MapRouteSegmentRequest] objects,
  ///   each describing an origin, destination, and routing profile
  ///   for that segment.
  ///
  /// Returns:
  /// A [Future] resolving to a single aggregated [MapRoute] composed
  /// of the provided segments. The resulting route should maintain
  /// correct ordering, cumulative distance, duration, and polyline
  /// continuity.
  ///
  /// Notes:
  /// - Intended for advanced scenarios such as mixed transport modes
  ///   (e.g., walk → bike → transit).
  /// - Implementations should ensure proper stitching of segment
  ///   geometries and metadata.
  ///
  /// Throws:
  /// - [Exception] if any segment fails to build.
  /// - Implementation-specific errors for invalid segment definitions.
  Future<MapRoute> buildMultiSegmentRoute({
    required List<MapRouteSegmentRequest> segments,
  });
}
