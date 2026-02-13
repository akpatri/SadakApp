import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/map_place.dart';

abstract class IHomeRepository {
  Future<LatLng> getCurrentLocation();

  Future<List<MapPlace>> searchPlaces(
    String query,
    LatLng currentLocation,
  );
}
