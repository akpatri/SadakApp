import 'package:open_route_service/open_route_service.dart';

abstract class IORSGeocode {
  Set<String> get geocodeSourcesAvailable;

  Set<String> get geocodeLayersAvailable;

  Future<GeoJsonFeatureCollection> geocodeAutoCompleteGet({
    required String text,
    ORSCoordinate? focusPointCoordinate,
    ORSCoordinate? boundaryRectangleMinCoordinate,
    ORSCoordinate? boundaryRectangleMaxCoordinate,
    String? boundaryCountry,
    List<String>? sources,
    List<String> layers = const <String>[],
  });

  Future<GeoJsonFeatureCollection> geocodeSearchGet({
    required String text,
    ORSCoordinate? focusPointCoordinate,
    ORSCoordinate? boundaryRectangleMinCoordinate,
    ORSCoordinate? boundaryRectangleMaxCoordinate,
    ORSCoordinate? boundaryCircleCoordinate,
    double boundaryCircleRadius = 50,
    String? boundaryGid,
    String? boundaryCountry,
    List<String>? sources,
    List<String> layers = const <String>[],
    int size = 10,
  });

  Future<GeoJsonFeatureCollection> geocodeSearchStructuredGet({
    String? address,
    String? neighbourhood,
    String? country,
    String? postalcode,
    String? region,
    String? county,
    String? locality,
    String? borough,
    ORSCoordinate? focusPointCoordinate,
    ORSCoordinate? boundaryRectangleMinCoordinate,
    ORSCoordinate? boundaryRectangleMaxCoordinate,
    ORSCoordinate? boundaryCircleCoordinate,
    double boundaryCircleRadius = 50,
    String? boundaryCountry,
    List<String>? sources,
    List<String> layers = const <String>[],
    int size = 10,
  });

  Future<GeoJsonFeatureCollection> geocodeReverseGet({
    required ORSCoordinate point,
    double boundaryCircleRadius = 1,
    int size = 10,
    List<String> layers = const <String>[],
    List<String>? sources,
    String? boundaryCountry,
  });
}
