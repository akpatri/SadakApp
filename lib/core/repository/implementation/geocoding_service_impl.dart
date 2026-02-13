import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_place.dart';
import 'package:sadak/core/service/map/interface/i_geocoding_service.dart';

class GeocodingServiceImpl implements IGeocodingService {
  final Dio _dio;
  final String _apiKey;

  GeocodingServiceImpl({
    required Dio dio,
    required String apiKey,
  })  : _dio = dio,
        _apiKey = apiKey;

  @override
  Future<List<MapPlace>> searchPlaces(
    String query,
    LatLng proximity,
  ) async {
    final response = await _dio.get(
      'https://your-provider.com/search',
      queryParameters: {
        'q': query,
        'lat': proximity.latitude,
        'lon': proximity.longitude,
        'key': _apiKey,
      },
    );

    final results = response.data['results'] as List;

    return results.map((e) {
      return MapPlace(
       
        name: e['name'],
        
        location: LatLng(e['lat'], e['lon']),
      );
    }).toList();
  }
}
