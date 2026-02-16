import 'package:dart_geohash/dart_geohash.dart';
import 'package:open_route_service/open_route_service.dart';

class SegmentCacheKey {
  final String value;

  SegmentCacheKey._(this.value);

  factory SegmentCacheKey.create({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required ORSProfile profile,
    int precision = 7,
  }) {
    final geo = GeoHasher();

    final startHash = geo.encode(startLat, startLng, precision: precision);
    final endHash = geo.encode(endLat, endLng, precision: precision);

    return SegmentCacheKey._(
      "${profile.name}_$startHash$endHash",
    );
  }
}
