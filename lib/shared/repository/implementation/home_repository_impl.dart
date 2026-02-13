import 'package:latlong2/latlong.dart';
import 'package:sadak/shared/model/map/map_place.dart';
import 'package:sadak/shared/repository/interface/i_home_repository.dart';

class HomeRepositoryImpl implements IHomeRepository{
  @override
  Future<LatLng> getCurrentLocation() {
    // TODO: implement getCurrentLocation
    throw UnimplementedError();
  }

  @override
  Future<List<MapPlace>> searchPlaces(String query, LatLng currentLocation) {
    // TODO: implement searchPlaces
    throw UnimplementedError();
  }
}