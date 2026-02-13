import 'package:latlong2/latlong.dart';

/// Defines the contract for encoding and decoding geographic
/// polylines using a compact string representation.
///
/// Implementations of [IPolylineCodec] typically follow a
/// polyline encoding algorithm (e.g., Google Polyline Algorithm)
/// to efficiently compress latitude/longitude coordinates for
/// transmission or storage.
///
/// This abstraction ensures consistent polyline transformation
/// logic across routing, map rendering, and network layers.
abstract class IPolylineCodec {
  /// Decodes an encoded polyline [encoded] string into a list
  /// of [LatLng] coordinates.
  ///
  /// Parameters:
  /// - [encoded]: A compressed polyline string.
  /// - [precision]: The coordinate precision used during encoding.
  ///   Defaults to `6`, meaning coordinates were multiplied by 10^6
  ///   before encoding.
  ///
  /// Returns:
  /// A list of [LatLng] points representing the decoded path.
  /// The list may be empty if the input string is empty.
  ///
  /// Throws:
  /// - [FormatException] if the encoded string is malformed.
  /// - [Exception] for implementation-specific decoding failures.
  ///
  /// Notes:
  /// - The [precision] value must match the precision used during encoding.
  /// - Precision mismatches will result in incorrect coordinates.
  List<LatLng> decode(String encoded, {int precision = 6});

  /// Encodes a list of geographic [points] into a compressed
  /// polyline string.
  ///
  /// Parameters:
  /// - [points]: The list of [LatLng] coordinates to encode.
  /// - [precision]: The coordinate precision to use during encoding.
  ///   Defaults to `6`, meaning coordinates are multiplied by 10^6
  ///   before compression.
  ///
  /// Returns:
  /// A compressed polyline string representation of the input points.
  /// Returns an empty string if [points] is empty.
  ///
  /// Throws:
  /// - [Exception] for implementation-specific encoding failures.
  ///
  /// Notes:
  /// - Higher precision increases accuracy but also increases
  ///   the length of the encoded string.
  /// - Precision should be consistent with the routing provider
  ///   or map backend used in the application.
  String encode(List<LatLng> points, {int precision = 6});
}
