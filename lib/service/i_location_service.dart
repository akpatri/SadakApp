import 'package:latlong2/latlong.dart';

abstract class ILocationService {
  Future<LatLng> getCurrentLocation();
}
