import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_direction_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_elevattion_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_geo_code_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_isochrone_service.dart';
import 'package:sadak/service/interface/map/ors/i_ors_positions_service.dart';
import 'package:sadak/service/interface/map/ors/i_orx_matrix_service.dart';
import 'package:sadak/service/interface/map/ors/i_orx_optimization_service.dart';

class ORSMapService
    implements
        IORSDirection,
        IORSElevattion,
        IORSGeocode,
        IORSIsochrones,
        IORSMatrix,
        IORSOptimization,
        IORSPois {
  final OpenRouteService _orsClient;
  ORSMapService({required OpenRouteService openRouteServiceClient})
    : _orsClient = openRouteServiceClient;

  @override
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
  }) async {
    return await _orsClient.directionsMultiRouteCoordsPost(
      coordinates: coordinates,
      alternativeRoutes: alternativeRoutes,
      attributes: attributes,
      continueStraight: continueStraight,
      elevation: elevation,
      extraInfo: extraInfo,
      geometrySimplify: geometrySimplify,
      id: id,
      instructions: instructions,
      instructionsFormat: instructionsFormat,
      language: language,
      maneuvers: maneuvers,
      options: options,
      preference: preference,
      radiuses: radiuses,
      roundaboutExits: roundaboutExits,
      skipSegments: skipSegments,
      suppressWarnings: suppressWarnings,
      units: units,
      geometry: geometry,
      maximumSpeed: maximumSpeed,
      profileOverride: profileOverride,
    );
  }

  @override
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
  }) async {
    final result = await _orsClient.directionsMultiRouteDataPost(
      coordinates: coordinates,
      alternativeRoutes: alternativeRoutes,
      attributes: attributes,
      continueStraight: continueStraight,
      elevation: elevation,
      extraInfo: extraInfo,
      geometrySimplify: geometrySimplify,
      id: id,
      instructions: instructions,
      instructionsFormat: instructionsFormat,
      language: language,
      maneuvers: maneuvers,
      options: options,
      preference: preference,
      radiuses: radiuses,
      roundaboutExits: roundaboutExits,
      skipSegments: skipSegments,
      suppressWarnings: suppressWarnings,
      units: units,
      geometry: geometry,
      maximumSpeed: maximumSpeed,
      profileOverride: profileOverride,
    );

    return result;
  }

  @override
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
  }) async {
    return await _orsClient.directionsMultiRouteGeoJsonPost(
      coordinates: coordinates,
      alternativeRoutes: alternativeRoutes,
      attributes: attributes,
      continueStraight: continueStraight,
      elevation: elevation,
      extraInfo: extraInfo,
      geometrySimplify: geometrySimplify,
      id: id,
      instructions: instructions,
      instructionsFormat: instructionsFormat,
      language: language,
      maneuvers: maneuvers,
      options: options,
      preference: preference,
      radiuses: radiuses,
      roundaboutExits: roundaboutExits,
      skipSegments: skipSegments,
      suppressWarnings: suppressWarnings,
      units: units,
      geometry: geometry,
      maximumSpeed: maximumSpeed,
      profileOverride: profileOverride,
    );
  }

  @override
  Future<List<ORSCoordinate>> directionsRouteCoordsGet({
    required ORSCoordinate startCoordinate,
    required ORSCoordinate endCoordinate,
    ORSProfile? profileOverride,
  }) async {
    return await _orsClient.directionsRouteCoordsGet(
      startCoordinate: startCoordinate,
      endCoordinate: endCoordinate,
      profileOverride: profileOverride,
    );
  }

  @override
  Future<GeoJsonFeatureCollection> directionsRouteGeoJsonGet({
    required ORSCoordinate startCoordinate,
    required ORSCoordinate endCoordinate,
    ORSProfile? profileOverride,
  }) async {
    return await _orsClient.directionsRouteGeoJsonGet(
      startCoordinate: startCoordinate,
      endCoordinate: endCoordinate,
      profileOverride: profileOverride,
    );
  }

  @override
  Future<ElevationData> elevationLinePost({
    required Object geometry,
    required String formatIn,
    String formatOut = 'geojson',
    String dataset = 'srtm',
  }) async {
    return await _orsClient.elevationLinePost(
      geometry: geometry,
      formatIn: formatIn,
      formatOut: formatOut,
      dataset: dataset,
    );
  }

  @override
  Future<ElevationData> elevationPointGet({
    required ORSCoordinate geometry,
    String formatOut = 'geojson',
    String dataset = 'srtm',
  }) async {
    return await _orsClient.elevationPointGet(
      geometry: geometry,
      formatOut: formatOut,
      dataset: dataset,
    );
  }

  @override
  Future<ElevationData> elevationPointPost({
    required ORSCoordinate geometry,
    String formatIn = 'point',
    String formatOut = 'geojson',
    String dataset = 'srtm',
  }) async {
    return await _orsClient.elevationPointPost(
      geometry: geometry,
      formatIn: formatIn,
      formatOut: formatOut,
      dataset: dataset,
    );
  }

  @override
  Future<GeoJsonFeatureCollection> geocodeAutoCompleteGet({
    required String text,
    ORSCoordinate? focusPointCoordinate,
    ORSCoordinate? boundaryRectangleMinCoordinate,
    ORSCoordinate? boundaryRectangleMaxCoordinate,
    String? boundaryCountry,
    List<String>? sources,
    List<String> layers = const <String>[],
  }) async {
    return await _orsClient.geocodeAutoCompleteGet(
      text: text,
      focusPointCoordinate: focusPointCoordinate,
      boundaryRectangleMinCoordinate: boundaryRectangleMinCoordinate,
      boundaryRectangleMaxCoordinate: boundaryRectangleMaxCoordinate,
      boundaryCountry: boundaryCountry,
      sources: sources,
      layers: layers,
    );
  }

  @override
  Set<String> get geocodeLayersAvailable => _orsClient.geocodeLayersAvailable;

  @override
Future<GeoJsonFeatureCollection> geocodeReverseGet({
  required ORSCoordinate point,
  double boundaryCircleRadius = 1,
  int size = 10,
  List<String> layers = const <String>[],
  List<String>? sources,
  String? boundaryCountry,
}) async {
  return await _orsClient.geocodeReverseGet(
    point: point,
    boundaryCircleRadius: boundaryCircleRadius,
    size: size,
    layers: layers,
    sources: sources,
    boundaryCountry: boundaryCountry,
  );
}


  @override
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
}) {
  return _orsClient.geocodeSearchGet(
    text: text,
    focusPointCoordinate: focusPointCoordinate,
    boundaryRectangleMinCoordinate: boundaryRectangleMinCoordinate,
    boundaryRectangleMaxCoordinate: boundaryRectangleMaxCoordinate,
    boundaryCircleCoordinate: boundaryCircleCoordinate,
    boundaryCircleRadius: boundaryCircleRadius,
    boundaryGid: boundaryGid,
    boundaryCountry: boundaryCountry,
    sources: sources,
    layers: layers,
    size: size,
  );
}


  @override
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
}) {
  return _orsClient.geocodeSearchStructuredGet(
    address: address,
    neighbourhood: neighbourhood,
    country: country,
    postalcode: postalcode,
    region: region,
    county: county,
    locality: locality,
    borough: borough,
    focusPointCoordinate: focusPointCoordinate,
    boundaryRectangleMinCoordinate: boundaryRectangleMinCoordinate,
    boundaryRectangleMaxCoordinate: boundaryRectangleMaxCoordinate,
    boundaryCircleCoordinate: boundaryCircleCoordinate,
    boundaryCircleRadius: boundaryCircleRadius,
    boundaryCountry: boundaryCountry,
    sources: sources,
    layers: layers,
    size: size,
  );
}


  @override
Set<String> get geocodeSourcesAvailable =>
    _orsClient.geocodeSourcesAvailable;


  @override
Future<GeoJsonFeatureCollection> isochronesPost({
  required List<ORSCoordinate> locations,
  required List<int> range,
  List<String> attributes = const <String>[],
  String? id,
  bool intersections = false,
  int? interval,
  String locationType = 'start',
  Map<String, dynamic>? options,
  String rangeType = 'time',
  int? smoothing,
  String areaUnits = 'm',
  String units = 'm',
  ORSProfile? profileOverride,
}) {
  return _orsClient.isochronesPost(
    locations: locations,
    range: range,
    attributes: attributes,
    id: id,
    intersections: intersections,
    interval: interval,
    locationType: locationType,
    options: options,
    rangeType: rangeType,
    smoothing: smoothing,
    areaUnits: areaUnits,
    units: units,
    profileOverride: profileOverride,
  );
}


  @override
Future<TimeDistanceMatrix> matrixPost({
  required List<ORSCoordinate> locations,
  List<int>? destinations,
  String? id,
  List<String> metrics = const <String>['duration'],
  List<dynamic>? metricsStrings,
  bool resolveLocations = false,
  List<int>? sources,
  String units = 'm',
  ORSProfile? profileOverride,
}) {
  return _orsClient.matrixPost(
    locations: locations,
    destinations: destinations,
    id: id,
    metrics: metrics,
    metricsStrings: metricsStrings,
    resolveLocations: resolveLocations,
    sources: sources,
    units: units,
    profileOverride: profileOverride,
  );
}


  @override
Future<OptimizationData> optimizationDataPost({
  required List<VroomJob> jobs,
  required List<VroomVehicle> vehicles,
  List<dynamic>? matrix,
  Object? options,
}) {
  return _orsClient.optimizationDataPost(
    jobs: jobs,
    vehicles: vehicles,
    matrix: matrix,
    options: options,
  );
}


  @override
Future<PoisData> poisDataPost({
  required String request,
  Object? geometry,
  Object? filters,
  int? limit,
  String? sortBy,
}) {
  return _orsClient.poisDataPost(
    request: request,
    geometry: geometry,
    filters: filters,
    limit: limit,
    sortBy: sortBy,
  );
}

}
