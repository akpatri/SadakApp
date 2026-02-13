import 'package:latlong2/latlong.dart';

abstract class IPolylineCodec {
  List<LatLng> decode(String encoded, {int precision = 6});
  String encode(List<LatLng> points, {int precision = 6});
}
