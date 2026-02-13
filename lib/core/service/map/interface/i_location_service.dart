import 'package:latlong2/latlong.dart';

/// Defines the contract for a location service responsible for
/// providing the device's current geographic position and
/// continuous location updates.
///
/// Implementations of [ILocationService] may rely on platform-specific
/// location APIs (e.g., GPS, network-based positioning) and should
/// handle permission checks, accuracy settings, and error handling
/// internally.
///
/// This abstraction allows the application to remain independent
/// from any specific location provider or plugin.
abstract class ILocationService {
  /// Retrieves the device's current geographic location.
  ///
  /// Returns:
  /// A [Future] that resolves to the current [LatLng] coordinate.
  ///
  /// Throws:
  /// - [Exception] if location permissions are denied.
  /// - [Exception] if location services are disabled.
  /// - Implementation-specific errors for timeout, platform failures,
  ///   or unavailable positioning data.
  ///
  /// Notes:
  /// - Implementations should request runtime permissions if needed.
  /// - Accuracy level and timeout behavior are implementation-defined.
  /// - This method is intended for one-time location retrieval.
  Future<LatLng> getCurrentLocation();

  /// Provides a continuous stream of location updates.
  ///
  /// Returns:
  /// A [Stream] of [LatLng] values that emits new coordinates
  /// as the device location changes.
  ///
  /// Stream Behavior:
  /// - The stream may emit updates based on distance changes,
  ///   time intervals, or provider-defined thresholds.
  /// - The stream should properly handle subscription lifecycle
  ///   (pause, resume, cancel) to prevent memory leaks.
  ///
  /// Throws:
  /// - Errors may be emitted through the stream if permissions
  ///   are revoked or the location service becomes unavailable.
  ///
  /// Notes:
  /// - Intended for real-time tracking (e.g., navigation, live updates).
  /// - Consumers are responsible for managing the stream subscription.
  Stream<LatLng> getLocationStream();
}
