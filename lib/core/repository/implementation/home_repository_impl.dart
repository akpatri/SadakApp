import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';
import 'package:sadak/core/repository/interface/i_home_repository.dart';
import 'package:sadak/core/service/map/interface/i_geocoding_service.dart';
import 'package:sadak/core/service/map/interface/i_location_service.dart';

class HomeRepositoryImpl implements IHomeRepository {
  final ILocationService _locationService;
  final IGeocodingService _geocodingService;

  HomeRepositoryImpl({
    required ILocationService locationService,
    required IGeocodingService geocodingService,
  })  : _locationService = locationService,
        _geocodingService = geocodingService;

  @override
  Future<LatLng> getCurrentLocation() async {
    return _locationService.getCurrentLocation();
  }

  @override
  Future<List<MapPlace>> searchPlaces(
    String query,
    LatLng currentLocation,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return _geocodingService.searchPlaces(
      query,
      currentLocation,
    );
  }
}
