import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';

/// Defines the contract for a geocoding service responsible for
/// converting human-readable location queries into structured
/// geographic results.
///
/// Implementations of [IGeocodingService] may use external providers
/// (e.g., REST APIs), local databases, or cached sources to resolve
/// place searches.
///
/// This abstraction ensures the app remains provider-agnostic and
/// allows easy replacement or extension of geocoding backends.
abstract class IGeocodingService {
    /// Searches for places matching the given [query], optionally
  /// biased by a geographic [proximity].
  ///
  /// Parameters:
  /// - [query]: A human-readable location string (e.g., "Central Park",
  ///   "Coffee near Times Square", "221B Baker Street").
  /// - [proximity]: A geographic coordinate used to bias or rank
  ///   results closer to the specified location. This does not
  ///   necessarily restrict results but influences relevance.
  ///
  /// Returns:
  /// A [Future] that resolves to a list of [MapPlace] results ordered
  /// by relevance. The list may be empty if no matches are found.
  ///
  /// Throws:
  /// - [Exception] if the search operation fails due to network errors,
  ///   provider issues, or parsing failures.
  /// - Implementation-specific errors depending on the underlying
  ///   geocoding provider.
  ///
  /// Notes:
  /// - Implementations should handle debouncing and rate limiting
  ///   where appropriate.
  /// - Results should be normalized into the [MapPlace] domain model
  ///   to maintain consistency across providers.
  Future<List<MapPlace>> searchPlaces(
    String query,
    LatLng proximity,
  );
}
