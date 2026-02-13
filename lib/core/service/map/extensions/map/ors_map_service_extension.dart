import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:sadak/core/model/map/map_distance_matrix.dart';
import 'package:sadak/core/model/map/map_place.dart';
import 'package:sadak/core/model/map/map_route.dart';
import 'package:sadak/core/model/map/map_route_segment.dart';
import 'package:sadak/core/model/map/transport_file_enum.dart';
import 'package:sadak/core/service/map/extensions/map/ors_profile_mapper_extension.dart';
import 'package:sadak/core/service/map/implementation/map_service_impl.dart';

extension ORSMapService on MapServiceImpl {
  Future<List<MapRoute>> getDirectionsFromORS({
    required List<LatLng> coordinates,
    required TransportProfile profile,
    bool alternatives = false,
  }) async {
    if (coordinates.length < 2) {
      throw ArgumentError('At least 2 coordinates required');
    }

    final profileString = profile.toORSProfile();

    final response = await dio.post(
      'https://api.openrouteservice.org/v2/directions/$profileString',
      options: Options(
        headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      ),
      data: {
        "coordinates": coordinates
            .map((c) => [c.longitude, c.latitude])
            .toList(),
        "geometry": true,
        "geometry_format": "geojson",
        if (alternatives)
          "alternative_routes": {"share_factor": 0.6, "target_count": 2},
      },
    );

    final data = response.data;

    if (data == null || data['routes'] == null) {
      throw Exception('Invalid ORS response');
    }

    final List routesJson = data['routes'];

    return routesJson.map<MapRoute>((routeJson) {
      final summary = routeJson['summary'] ?? {};

      final totalDistance = (summary['distance'] as num?)?.toDouble() ?? 0.0;

      final totalDuration = (summary['duration'] as num?)?.toDouble() ?? 0.0;

      final geometryData = routeJson['geometry'];
      final List coordinatesJson =
          (geometryData?['coordinates'] as List?) ?? [];

      final fullGeometry = coordinatesJson
          .map<LatLng>(
            (point) => LatLng(point[1] as double, point[0] as double),
          )
          .toList();

      // ---- Build ONE segment for entire route ----
      final segmentCost = estimateCost(
        distanceMeters: totalDistance,
        profile: profile,
      );

      final segments = [
        MapRouteSegment(
          profile: profile,
          distanceMeters: totalDistance,
          durationSeconds: totalDuration,
          cost: segmentCost,
          geometry: fullGeometry,
        ),
      ];

      return MapRoute(
        totalDistanceMeters: totalDistance,
        totalDurationSeconds: totalDuration,
        totalCost: segmentCost,
        segments: segments,
        fullGeometry: fullGeometry,
      );
    }).toList();
  }

  Future<MapPlace?> reverseGeocodeFromORS(LatLng location) async {
    final response = await dio.post(
      'https://api.openrouteservice.org/geocode/reverse',
      options: Options(
        headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      ),
      data: {
        "point": {"lon": location.longitude, "lat": location.latitude},
        "size": 1,
      },
    );

    final features = response.data['features'] as List?;

    if (features == null || features.isEmpty) {
      return null;
    }

    final feature = features.first;
    final properties = feature['properties'];
    final geometry = feature['geometry'];

    final coords = geometry['coordinates'];

    final name =
        properties['name'] ?? properties['label'] ?? 'Unknown location';

    return MapPlace(
      name: name,
      location: LatLng(coords[1], coords[0]),
      distanceKm: null, // reverse geocode doesn’t provide this
    );
  }

  Future<List<MapPlace>> searchPlacesFromORS({
    required String query,
    required LatLng near,
    int limit = 5,
  }) async {
    final response = await dio.post(
      'https://api.openrouteservice.org/geocode/search',
      options: Options(
        headers: {'Authorization': apiKey, 'Content-Type': 'application/json'},
      ),
      data: {
        "text": query,
        "focus.point": {"lon": near.longitude, "lat": near.latitude},
        "size": limit,
      },
    );

    final features = response.data['features'] as List?;

    if (features == null || features.isEmpty) {
      return [];
    }

    return features.map<MapPlace>((feature) {
      final properties = feature['properties'];
      final geometry = feature['geometry'];
      final coords = geometry['coordinates'];

      final location = LatLng(coords[1], coords[0]);

      final distanceKm = _calculateDistanceKm(near, location);

      final name = properties['name'] ?? properties['label'] ?? query;

      return MapPlace(name: name, location: location, distanceKm: distanceKm);
    }).toList();
  }

  double _calculateDistanceKm(LatLng a, LatLng b) {
    const Distance distance = Distance();
    final meters = distance.as(LengthUnit.Meter, a, b);
    return meters / 1000.0;
  }

 Future<LatLng> snapToRoadFromORS({
    required LatLng location,
    required TransportProfile profile,
  }) async {
    final profileString = profile.toORSProfile();

    final response = await dio.post(
      'https://api.openrouteservice.org/v2/snap/$profileString',
      options: Options(
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "locations": [
          [location.longitude, location.latitude]
        ],
      },
    );

    final snapped = response.data['locations'] as List?;

    if (snapped == null || snapped.isEmpty) {
      throw Exception('Unable to snap location to road');
    }

    final snappedCoords = snapped.first['location'];

    return LatLng(
      snappedCoords[1],
      snappedCoords[0],
    );
  }


   Future<MapDistanceMatrix> getDistanceMatrixFromORS({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    required TransportProfile profile,
  }) async {
    if (origins.isEmpty || destinations.isEmpty) {
      throw ArgumentError('Origins and destinations cannot be empty');
    }

    final profileString = profile.toORSProfile();

    // ORS requires all locations combined
    final allLocations = [
      ...origins,
      ...destinations,
    ];

    final response = await dio.post(
      'https://api.openrouteservice.org/v2/matrix/$profileString',
      options: Options(
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
      ),
      data: {
        "locations": allLocations
            .map((c) => [c.longitude, c.latitude])
            .toList(),
        "sources": List.generate(origins.length, (i) => i),
        "destinations": List.generate(
          destinations.length,
          (i) => i + origins.length,
        ),
        "metrics": ["distance", "duration"],
      },
    );

    final distancesJson =
        response.data['distances'] as List;

    final durationsJson =
        response.data['durations'] as List;

    final distances = distancesJson
        .map<List<double>>(
          (row) => (row as List)
              .map<double>((e) => (e as num).toDouble())
              .toList(),
        )
        .toList();

    final durations = durationsJson
        .map<List<double>>(
          (row) => (row as List)
              .map<double>((e) => (e as num).toDouble())
              .toList(),
        )
        .toList();

    return MapDistanceMatrix(
      distances: distances,
      durations: durations,
    );
  }


}
