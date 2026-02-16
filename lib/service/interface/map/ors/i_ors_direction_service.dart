import 'package:open_route_service/open_route_service.dart';

abstract class IORSDirection {
  Future<GeoJsonFeatureCollection> directionsRouteGeoJsonGet({
    required ORSCoordinate startCoordinate,
    required ORSCoordinate endCoordinate,
    ORSProfile? profileOverride,
  });

  Future<List<ORSCoordinate>> directionsRouteCoordsGet({
    required ORSCoordinate startCoordinate,
    required ORSCoordinate endCoordinate,
    ORSProfile? profileOverride,
  });

  Future<GeoJsonFeatureCollection> directionsMultiRouteGeoJsonPost({
    required List<ORSCoordinate> coordinates,
    Object? alternativeRoutes,
    List<String>? attributes,
    bool continueStraight = false,
    bool? elevation,
    List<String>? extraInfo,
    bool geometrySimplify = false,
    String? id,
    bool instructions = true,
    String instructionsFormat = 'text',
    String language = 'en',
    bool maneuvers = false,
    Object? options,
    String preference = 'recommended',
    List<int>? radiuses,
    bool roundaboutExits = false,
    List<int>? skipSegments,
    bool suppressWarnings = false,
    String units = 'm',
    bool geometry = true,
    int? maximumSpeed,
    ORSProfile? profileOverride,
  });

  Future<List<ORSCoordinate>> directionsMultiRouteCoordsPost({
    required List<ORSCoordinate> coordinates,
    Object? alternativeRoutes,
    List<String>? attributes,
    bool continueStraight = false,
    bool? elevation,
    List<String>? extraInfo,
    bool geometrySimplify = false,
    String? id,
    bool instructions = true,
    String instructionsFormat = 'text',
    String language = 'en',
    bool maneuvers = false,
    Object? options,
    String preference = 'recommended',
    List<int>? radiuses,
    bool roundaboutExits = false,
    List<int>? skipSegments,
    bool suppressWarnings = false,
    String units = 'm',
    bool geometry = true,
    int? maximumSpeed,
    ORSProfile? profileOverride,
  });

  Future<List<DirectionRouteData>> directionsMultiRouteDataPost({
    required List<ORSCoordinate> coordinates,
    Object? alternativeRoutes,
    List<String>? attributes,
    bool continueStraight = false,
    bool? elevation,
    List<String>? extraInfo,
    bool geometrySimplify = false,
    String? id,
    bool instructions = true,
    String instructionsFormat = 'text',
    String language = 'en',
    bool maneuvers = false,
    Object? options,
    String preference = 'recommended',
    List<int>? radiuses,
    bool roundaboutExits = false,
    List<int>? skipSegments,
    bool suppressWarnings = false,
    String units = 'm',
    bool geometry = true,
    int? maximumSpeed,
    ORSProfile? profileOverride,
  });
}
