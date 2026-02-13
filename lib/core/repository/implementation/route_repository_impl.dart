import 'package:latlong2/latlong.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';
import 'package:sadak/core/model/map/map_route_segment_request.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/repository/interface/i_route_repository.dart';
import 'package:dio/dio.dart';
import 'package:sadak/core/service/map/interface/i_polyline_codec.dart';

class ORSRouteRepositoryImpl implements IRouteRepository {
  final Dio _dio;
  final String _apiKey;
  final IPolylineCodec _polylineCodec;

  ORSRouteRepositoryImpl({
    required Dio dio,
    required String apiKey,
    required IPolylineCodec polylineCodec,
  })  : _dio = dio,
        _apiKey = apiKey,
        _polylineCodec = polylineCodec;

  // ---------------------------
  // PUBLIC METHODS
  // ---------------------------

  @override
  Future<MapRoute> fetchPrimaryRoute({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  }) async {
    final routes = await _fetchRoutes(
      coordinates: coordinates,
      profile: profile,
      alternatives: false,
    );

    return routes.first;
  }

  @override
  Future<List<MapRoute>> fetchAlternativeRoutes({
    required List<LatLng> coordinates,
    required TransportProfile profile,
  }) async {
    return _fetchRoutes(
      coordinates: coordinates,
      profile: profile,
      alternatives: true,
    );
  }

  @override
  Future<MapRoute> buildMultiSegmentRoute({
    required List<MapRouteSegmentRequest> segments,
  }) async {
    if (segments.isEmpty) {
      throw ArgumentError('Segments cannot be empty');
    }

    final builtSegments = <MapRoute>[];

    for (final segment in segments) {
      final route = await fetchPrimaryRoute(
        coordinates: [segment.start, segment.end],
        profile: segment.profile,
      );

      builtSegments.add(route);
    }

    double totalDistance = 0;
    double totalDuration = 0;
    final fullGeometry = <LatLng>[];
    final allSegments = <MapRouteSegment>[];

    for (final route in builtSegments) {
      totalDistance += route.totalDistanceMeters;
      totalDuration += route.totalDurationSeconds;
      fullGeometry.addAll(route.fullGeometry);
      allSegments.addAll(route.segments);
    }

    return MapRoute(
      totalDistanceMeters: totalDistance,
      totalDurationSeconds: totalDuration,
      totalCost: 0,
      segments: allSegments,
      fullGeometry: fullGeometry,
    );
  }

  // ---------------------------
  // PRIVATE METHODS
  // ---------------------------

  Future<List<MapRoute>> _fetchRoutes({
    required List<LatLng> coordinates,
    required TransportProfile profile,
    required bool alternatives,
  }) async {
    if (coordinates.length < 2) {
      throw ArgumentError('At least 2 coordinates required');
    }

    final orsProfile = _mapProfile(profile);

    final response = await _dio.post(
      'directions/$orsProfile',
      options: Options(
        headers: {'Authorization': _apiKey},
      ),
      data: {
        "coordinates": coordinates
            .map((c) => [c.longitude, c.latitude])
            .toList(),
        "alternative_routes": alternatives
            ? {
                "target_count": 3,
                "share_factor": 0.6,
              }
            : false,
      },
    );

    final routesJson = response.data['routes'] as List;

    return routesJson
        .map((r) => _mapToDomain(r, profile))
        .toList();
  }

  MapRoute _mapToDomain(dynamic routeJson, TransportProfile profile) {
    final summary = routeJson['summary'];

    final distance =
        (summary['distance'] as num).toDouble();
    final duration =
        (summary['duration'] as num).toDouble();

    final encodedGeometry = routeJson['geometry'] as String;

    final geometry =
        _polylineCodec.decode(encodedGeometry, precision: 6);

    final segment = MapRouteSegment(
      profile: profile,
      distanceMeters: distance,
      durationSeconds: duration,
      cost: 0,
      geometry: geometry,
    );

    return MapRoute(
      totalDistanceMeters: distance,
      totalDurationSeconds: duration,
      totalCost: 0,
      segments: [segment],
      fullGeometry: geometry,
    );
  }

  String _mapProfile(TransportProfile profile) {
    switch (profile) {
      case TransportProfile.driving:
        return 'driving-car';
      case TransportProfile.cycling:
      case TransportProfile.bikeSharing:
        return 'cycling-regular';
      case TransportProfile.walking:
        return 'foot-walking';
      case TransportProfile.bus:
      case TransportProfile.train:
        return 'driving-car'; // fallback
       case TransportProfile.ferry:
        return 'driving-car';
    }
  }
}
