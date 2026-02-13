import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';

/// Defines the contract for home-screen related data operations.
///
/// [IHomeRepository] acts as a façade that coordinates location
/// retrieval and place search functionality required by the
/// home feature. It typically composes lower-level services
/// such as location and geocoding services while exposing
/// a simplified API to the presentation layer.
///
/// This abstraction keeps UI logic independent from
/// infrastructure concerns (e.g., GPS access, external APIs).
abstract class IHomeRepository {
  /// Retrieves the device's current geographic location.
  ///
  /// Returns:
  /// A [Future] resolving to the current [LatLng] coordinate.
  ///
  /// Throws:
  /// - [Exception] if permissions are denied.
  /// - [Exception] if location services are disabled.
  /// - Implementation-specific errors for timeout,
  ///   provider failure, or unavailable positioning data.
  ///
  /// Notes:
  /// - Intended for home-screen initialization and
  ///   user-centric search biasing.
  /// - Implementations may internally delegate to a
  ///   location service.
  Future<LatLng> getCurrentLocation();

  /// Searches for places matching the given [query],
  /// biased by the provided [currentLocation].
  ///
  /// Parameters:
  /// - [query]: A human-readable search string
  ///   (e.g., "Coffee", "Gas station", "Central Park").
  /// - [currentLocation]: The user's current position
  ///   used to improve relevance ranking.
  ///
  /// Returns:
  /// A [Future] resolving to a list of [MapPlace] results
  /// ordered by relevance. The list may be empty if
  /// no matches are found.
  ///
  /// Throws:
  /// - [Exception] if the search request fails due to
  ///   network or provider errors.
  ///
  /// Notes:
  /// - Implementations may internally delegate to a
  ///   geocoding/search service.
  /// - Results should be normalized into the [MapPlace]
  ///   domain model.
  Future<List<MapPlace>> searchPlaces(
    String query,
    LatLng currentLocation,
  );
}
