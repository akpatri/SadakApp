import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:sadak/core/di.dart';
import 'package:flutter/widget_previews.dart';

class MapView extends ConsumerStatefulWidget {
  final ORSCoordinate startCoordinate;
  final ORSCoordinate endCoordinate;
  final GeoJsonFeatureCollection geoJson;
  final ORSProfile? profileOverride;

  const MapView({
    super.key,
    required this.startCoordinate,
    required this.endCoordinate,
    required this.geoJson,
    this.profileOverride,
  });

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  final MapController _controller = MapController();

  bool _mapReady = false;
  bool _cameraFitted = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(mapViewModelProvider.notifier).initialize(
        startCoordinate: widget.startCoordinate,
        endCoordinate: widget.endCoordinate,
        collection: widget.geoJson,
      );
    });
  }

  void _tryFitCamera() {
    if (!_mapReady || _cameraFitted) return;

    final bounds = ref.read(mapViewModelProvider.notifier).bounds;
    if (bounds == null) return;

    _cameraFitted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 40,
            bottom: 40,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapViewModelProvider);
    final vm = ref.watch(mapViewModelProvider.notifier);

    // Listen only once per rebuild safely
    ref.listen(mapViewModelProvider, (previous, next) {
      next.whenData((_) => _tryFitCamera());
    });

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) {
          return FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: LatLng(
                widget.startCoordinate.latitude,
                widget.startCoordinate.longitude,
              ),
              initialZoom: 14,

              // Fully static map (no drag, no zoom)
              interactionOptions: const InteractionOptions(
                flags: 0,
              ),

              onMapReady: () {
                _mapReady = true;
                _tryFitCamera();
              },
            ),
            children: [
              _buildTileLayer(),
              PolygonLayer(polygons: vm.polygons),
              PolylineLayer(polylines: vm.polylines),
              MarkerLayer(markers: vm.markers),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
      userAgentPackageName: 'com.example.app',
    );
  }
}


@Preview(name: "MapView - Mock Preview")
Widget mapViewPreview() {
  const start = ORSCoordinate(latitude: 20.2961, longitude: 85.8245);
  const end = ORSCoordinate(latitude: 20.3000, longitude: 85.8200);

  const markerFeature = GeoJsonFeature(
    type: "Feature",
    properties: {"name": "POI Marker", "type": "poi"},
    geometry: GeoJsonFeatureGeometry(
      type: "Point",
      internalType: GsonFeatureGeometryCoordinatesType.single,
      coordinates: [
        [ORSCoordinate(latitude: 20.2975, longitude: 85.8220)],
      ],
    ),
  );

  const polylineFeature = GeoJsonFeature(
    type: "Feature",
    properties: {"name": "Mock Route", "type": "route"},
    geometry: GeoJsonFeatureGeometry(
      type: "LineString",
      internalType: GsonFeatureGeometryCoordinatesType.list,
      coordinates: [
        [
          ORSCoordinate(latitude: 20.2961, longitude: 85.8245),
          ORSCoordinate(latitude: 20.2970, longitude: 85.8230),
          ORSCoordinate(latitude: 20.2980, longitude: 85.8220),
          ORSCoordinate(latitude: 20.2990, longitude: 85.8210),
          ORSCoordinate(latitude: 20.3000, longitude: 85.8200),
        ],
      ],
    ),
  );

  const polygonFeature = GeoJsonFeature(
    type: "Feature",
    properties: {"name": "Mock Zone", "type": "zone"},
    geometry: GeoJsonFeatureGeometry(
      type: "Polygon",
      internalType: GsonFeatureGeometryCoordinatesType.listList,
      coordinates: [
        [
          ORSCoordinate(latitude: 20.2955, longitude: 85.8250),
          ORSCoordinate(latitude: 20.2955, longitude: 85.8210),
          ORSCoordinate(latitude: 20.2985, longitude: 85.8210),
          ORSCoordinate(latitude: 20.2985, longitude: 85.8250),
          ORSCoordinate(latitude: 20.2955, longitude: 85.8250),
        ],
      ],
    ),
  );

  const collection = GeoJsonFeatureCollection(
    bbox: [],
    features: [markerFeature, polylineFeature, polygonFeature],
  );

  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: MapView(
        startCoordinate: start,
        endCoordinate: end,
        geoJson: collection,
      ),
    ),
  );
}
