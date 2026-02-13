import 'package:latlong2/latlong.dart';

/// ===============================================================
/// MAP PLACE (Geocoding Result)
/// ===============================================================

class MapPlace {
  final String name;
  final LatLng location;
  final double? distanceKm;

  const MapPlace({required this.name, required this.location, this.distanceKm});
}