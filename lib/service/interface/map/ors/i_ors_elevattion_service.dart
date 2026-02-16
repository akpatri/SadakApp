import 'package:open_route_service/open_route_service.dart';

abstract class IORSElevattion {
  Future<ElevationData> elevationPointGet({
    required ORSCoordinate geometry,
    String formatOut = 'geojson',
    String dataset = 'srtm',
  });

  Future<ElevationData> elevationPointPost({
    required ORSCoordinate geometry,
    String formatIn = 'point',
    String formatOut = 'geojson',
    String dataset = 'srtm',
  });

  Future<ElevationData> elevationLinePost({
    required Object geometry,
    required String formatIn,
    String formatOut = 'geojson',
    String dataset = 'srtm',
  });
}
