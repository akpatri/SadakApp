import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/service/map/interface/i_polyline_codec.dart';

class PolylineCodecImpl implements IPolylineCodec{
  @override
  List<LatLng> decode(String encoded, {int precision = 6}) {
    // TODO: implement decode
    throw UnimplementedError();
  }

  @override
  String encode(List<LatLng> points, {int precision = 6}) {
    // TODO: implement encode
    throw UnimplementedError();
  }


}