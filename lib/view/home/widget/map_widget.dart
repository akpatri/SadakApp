import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:sadak/model/geo_json_property_model.dart';

class MapViewWidgetWidget extends ConsumerStatefulWidget {
  const MapViewWidgetWidget({super.key});

  @override
  ConsumerState<MapViewWidgetWidget> createState() =>
      _MapViewWidgetWidgetState();
}

class _MapViewWidgetWidgetState extends ConsumerState<MapViewWidgetWidget> {
  final MapController _controller = MapController();
  late final ProviderSubscription<AsyncValue<GeoJsonFeatureCollection>> _sub;
  @override
  void initState() {
    super.initState();

    _sub = ref.listenManual<AsyncValue<GeoJsonFeatureCollection>>(
      geoJsonCollectionProvider,
      (_, next) {
        next.whenData(_fitCamera);
      },
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  void _fitCamera(GeoJsonFeatureCollection collection) {
    final bounds = _calculateBounds(collection);
    if (bounds == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    });
  }

  LatLngBounds? _calculateBounds(GeoJsonFeatureCollection collection) {
    final points = <LatLng>[];

    for (final feature in collection.features) {
      for (final ring in feature.geometry.coordinates) {
        for (final c in ring) {
          points.add(LatLng(c.latitude, c.longitude));
        }
      }
    }

    if (points.isEmpty) return null;
    return LatLngBounds.fromPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    final asyncCollection = ref.watch(geoJsonCollectionProvider);

    return asyncCollection.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: _buildMap,
    );
  }

  Widget _buildMap(GeoJsonFeatureCollection collection) {
    final layers = _buildLayers(collection);

    return Scaffold(
      body: FlutterMap(
        mapController: _controller,
        options: const MapOptions(
          initialCenter: LatLng(20.5937, 78.9629), // India fallback
          initialZoom: 5,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.app',
          ),
          ...layers,
        ],
      ),
    );
  }

  List<Widget> _buildLayers(GeoJsonFeatureCollection collection) {
    final markers = <Marker>[];
    final polylines = <Polyline>[];
    final polygons = <Polygon>[];

    for (final feature in collection.features) {
      final property = GeoJsonProperty.fromDynamic(feature.properties);

      if (property == null) continue;

      if (!property.isVisible) continue;

      switch (feature.geometry.type) {
        case "Point":
          markers.add(_buildMarker(feature, property));
          break;

        case "LineString":
          polylines.add(_buildPolyline(feature, property));
          break;

        case "Polygon":
          polygons.add(_buildPolygon(feature));
          break;
      }
    }

    return [
      if (polygons.isNotEmpty) PolygonLayer(polygons: polygons),
      if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
      if (markers.isNotEmpty) MarkerLayer(markers: markers),
    ];
  }

  Marker _buildMarker(GeoJsonFeature feature, GeoJsonProperty property) {
    final coord = feature.geometry.coordinates.first.first;

    final iconData = _resolveMarkerIcon(property);
    final color = _resolveMarkerColor(property);

    return Marker(
      point: LatLng(coord.latitude, coord.longitude),
      width: 40,
      height: 40,
      child: Icon(iconData, color: color),
    );
  }

  IconData _resolveMarkerIcon(GeoJsonProperty property) {
    switch (property.type) {
      case "source":
        return Icons.trip_origin;
      case "destination":
        return Icons.flag;
      case "user_location":
        return Icons.my_location;
      default:
        return Icons.location_on;
    }
  }

  Color _resolveMarkerColor(GeoJsonProperty property) {
    switch (property.type) {
      case "source":
        return Colors.green;
      case "destination":
        return Colors.red;
      case "user_location":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Polyline _buildPolyline(GeoJsonFeature feature, GeoJsonProperty property) {
    final points = feature.geometry.coordinates.first
        .map((c) => LatLng(c.latitude, c.longitude))
        .toList();

    final color = _resolveRouteColor(property);

    return Polyline(
      points: points,
      strokeWidth: property.isSelected ? 6 : 4,
      color: color,
    );
  }

  Color _resolveRouteColor(GeoJsonProperty property) {
    if (property.isGptRoute) {
      return Colors.blue;
    }

    if (property.isCommunityRoute) {
      return Colors.green;
    }

    if (property.isOfficialRoute) {
      return Colors.grey;
    }

    return Colors.black;
  }

  Polygon _buildPolygon(GeoJsonFeature feature) {
    final points = feature.geometry.coordinates.first
        .map((c) => LatLng(c.latitude, c.longitude))
        .toList();

    return Polygon(
      points: points,
      color: Colors.purple.withOpacity(0.2),
      borderStrokeWidth: 2,
      borderColor: Colors.purple,
    );
  }
}
