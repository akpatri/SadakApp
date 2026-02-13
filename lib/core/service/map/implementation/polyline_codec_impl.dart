import 'package:latlong2/latlong.dart';
import 'package:sadak/core/service/map/interface/i_polyline_codec.dart';
import 'dart:math' as math;

class PolylineCodec implements IPolylineCodec {
  @override
  List<LatLng> decode(String encoded, {int precision = 6}) {
    final coordinates = <LatLng>[];

    int index = 0;
    int lat = 0;
    int lng = 0;
    final factor = math.pow(10, precision).toInt();

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLat =
          (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final deltaLng =
          (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      coordinates.add(
        LatLng(lat / factor, lng / factor),
      );
    }

    return coordinates;
  }

  @override
  String encode(List<LatLng> points, {int precision = 6}) {
    final buffer = StringBuffer();

    int prevLat = 0;
    int prevLng = 0;
    final factor = math.pow(10, precision).toInt();

    for (final point in points) {
      final lat = (point.latitude * factor).round();
      final lng = (point.longitude * factor).round();

      final deltaLat = lat - prevLat;
      final deltaLng = lng - prevLng;

      _encodeValue(deltaLat, buffer);
      _encodeValue(deltaLng, buffer);

      prevLat = lat;
      prevLng = lng;
    }

    return buffer.toString();
  }

  void _encodeValue(int value, StringBuffer buffer) {
    value = value < 0 ? ~(value << 1) : (value << 1);

    while (value >= 0x20) {
      buffer.writeCharCode((0x20 | (value & 0x1f)) + 63);
      value >>= 5;
    }

    buffer.writeCharCode(value + 63);
  }
}
